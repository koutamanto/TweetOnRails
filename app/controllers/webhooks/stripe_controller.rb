class Webhooks::StripeController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    payload    = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, ENV["STRIPE_WEBHOOK_SECRET"]
      )
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      render json: { error: e.message }, status: :bad_request and return
    end

    Rails.logger.info "[Stripe Webhook] event=#{event.type} id=#{event.id}"

    case event.type
    when "checkout.session.completed"       then handle_checkout_completed(event.data.object)
    when "customer.subscription.updated"    then handle_subscription_updated(event.data.object)
    when "customer.subscription.deleted"    then handle_subscription_deleted(event.data.object)
    when "invoice.payment_failed"           then handle_payment_failed(event.data.object)
    when "charge.refunded"                  then handle_charge_refunded(event.data.object)
    end

    render json: { received: true }
  end

  private

  def handle_checkout_completed(session)
    type = session.metadata&.[]("type")
    case type
    when "fan_subscription"
      handle_fan_subscription_checkout(session)
    when "premium_purchase"
      handle_premium_purchase_checkout(session)
    else
      handle_pro_checkout(session)
    end
  end

  # --- Robin Pro ---

  def handle_pro_checkout(session)
    unless session.mode == "subscription"
      Rails.logger.warn "[Stripe Webhook] handle_pro_checkout: unexpected mode=#{session.mode} session=#{session.id}"
      return
    end
    user = User.find_by(stripe_customer_id: session.customer)
    unless user
      Rails.logger.error "[Stripe Webhook] handle_pro_checkout: no user for customer=#{session.customer} session=#{session.id}"
      return
    end
    subscription = Stripe::Subscription.retrieve(session.subscription)
    activate_pro_subscription(user, subscription)
  end

  def handle_subscription_updated(subscription)
    if (fan_sub = FanSubscription.find_by(stripe_subscription_id: subscription.id))
      new_status = subscription.status == "active" ? :active : :past_due
      fan_sub.update!(
        status: new_status,
        current_period_end: Time.at(subscription.current_period_end)
      )
      Rails.logger.info "[Stripe Webhook] fan_subscription=#{fan_sub.id} status=#{new_status}"
    elsif (user = User.find_by(stripe_subscription_id: subscription.id))
      activate_pro_subscription(user, subscription)
    else
      Rails.logger.warn "[Stripe Webhook] handle_subscription_updated: no record for subscription=#{subscription.id}"
    end
  end

  def handle_subscription_deleted(subscription)
    if (fan_sub = FanSubscription.find_by(stripe_subscription_id: subscription.id))
      fan_sub.update!(status: :cancelled)
      Rails.logger.info "[Stripe Webhook] fan_subscription=#{fan_sub.id} cancelled"
    elsif (user = User.find_by(stripe_subscription_id: subscription.id))
      user.update!(
        plan: "free", subscription_status: "canceled",
        stripe_subscription_id: nil, subscription_current_period_end: nil
      )
      Rails.logger.info "[Stripe Webhook] user=#{user.id} plan=free (subscription deleted)"
    else
      Rails.logger.warn "[Stripe Webhook] handle_subscription_deleted: no record for subscription=#{subscription.id}"
    end
  end

  def handle_payment_failed(invoice)
    user = User.find_by(stripe_customer_id: invoice.customer)
    if user
      user.update!(subscription_status: "past_due")
      Rails.logger.info "[Stripe Webhook] user=#{user.id} payment_failed → past_due"
    else
      Rails.logger.warn "[Stripe Webhook] handle_payment_failed: no user for customer=#{invoice.customer}"
    end
  end

  def handle_charge_refunded(charge)
    payment_intent_id = charge.payment_intent
    return unless payment_intent_id.present?

    purchase = PremiumPurchase.find_by(stripe_payment_intent_id: payment_intent_id)
    if purchase
      PremiumPurchase.transaction do
        purchase.update!(status: :refunded)
        purchase.premium_post.creator_profile.decrement!(:total_earned_cents, purchase.creator_earned)
      end
      Rails.logger.info "[Stripe Webhook] purchase=#{purchase.id} refunded"
    else
      Rails.logger.warn "[Stripe Webhook] handle_charge_refunded: no purchase for payment_intent=#{payment_intent_id}"
    end
  end

  def activate_pro_subscription(user, subscription)
    price_id = subscription.items.data.first&.price&.id
    unless price_id.present?
      Rails.logger.error "[Stripe Webhook] activate_pro_subscription: no price_id for subscription=#{subscription.id} user=#{user.id}"
      return
    end
    plan_name = [ENV["STRIPE_PRO_MONTHLY_PRICE_ID"], ENV["STRIPE_PRO_YEARLY_PRICE_ID"]].include?(price_id) ? "pro" : "free"
    user.update!(
      plan: plan_name,
      subscription_status: subscription.status,
      stripe_subscription_id: subscription.id,
      subscription_current_period_end: Time.at(subscription.current_period_end)
    )
    Rails.logger.info "[Stripe Webhook] user=#{user.id} plan=#{plan_name} subscription_status=#{subscription.status}"
  end

  # --- Fan subscriptions ---

  def handle_fan_subscription_checkout(session)
    unless session.mode == "subscription"
      Rails.logger.warn "[Stripe Webhook] handle_fan_subscription_checkout: unexpected mode=#{session.mode} session=#{session.id}"
      return
    end
    fan_sub_id = session.metadata&.[]("fan_subscription_id")
    fan_sub = FanSubscription.find_by(id: fan_sub_id)
    unless fan_sub
      Rails.logger.error "[Stripe Webhook] handle_fan_subscription_checkout: no FanSubscription id=#{fan_sub_id} session=#{session.id}"
      return
    end

    # Idempotency: skip if already activated
    if fan_sub.active?
      Rails.logger.info "[Stripe Webhook] fan_subscription=#{fan_sub.id} already active, skipping"
      return
    end

    stripe_sub = Stripe::Subscription.retrieve(session.subscription)
    earned_cents = (fan_sub.amount_paid * (1 - CreatorProfile::PLATFORM_FEE_PERCENT / 100.0)).to_i

    FanSubscription.transaction do
      fan_sub.update!(
        status: :active,
        stripe_subscription_id: stripe_sub.id,
        current_period_end: Time.at(stripe_sub.current_period_end)
      )
      fan_sub.creator_profile.increment!(:total_earned_cents, earned_cents)
    end
    Rails.logger.info "[Stripe Webhook] fan_subscription=#{fan_sub.id} activated, earned=#{earned_cents}"
  end

  # --- PPV purchases ---

  def handle_premium_purchase_checkout(session)
    unless session.mode == "payment"
      Rails.logger.warn "[Stripe Webhook] handle_premium_purchase_checkout: unexpected mode=#{session.mode} session=#{session.id}"
      return
    end
    purchase_id = session.metadata&.[]("premium_purchase_id")
    purchase = PremiumPurchase.find_by(id: purchase_id)
    unless purchase
      Rails.logger.error "[Stripe Webhook] handle_premium_purchase_checkout: no PremiumPurchase id=#{purchase_id} session=#{session.id}"
      return
    end

    # Idempotency: skip if already completed
    if purchase.completed?
      Rails.logger.info "[Stripe Webhook] purchase=#{purchase.id} already completed, skipping"
      return
    end

    PremiumPurchase.transaction do
      purchase.update!(
        status: :completed,
        stripe_payment_intent_id: session.payment_intent
      )
      purchase.premium_post.increment!(:purchases_count)
      purchase.premium_post.creator_profile.increment!(:total_earned_cents, purchase.creator_earned)
    end
    Rails.logger.info "[Stripe Webhook] purchase=#{purchase.id} completed, earned=#{purchase.creator_earned}"
  end
end
