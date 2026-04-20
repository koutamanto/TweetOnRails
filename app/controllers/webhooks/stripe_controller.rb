class Webhooks::StripeController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

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

    case event.type
    when "checkout.session.completed"       then handle_checkout_completed(event.data.object)
    when "customer.subscription.updated"    then handle_subscription_updated(event.data.object)
    when "customer.subscription.deleted"    then handle_subscription_deleted(event.data.object)
    when "invoice.payment_failed"           then handle_payment_failed(event.data.object)
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
    return unless session.mode == "subscription"
    user = User.find_by(stripe_customer_id: session.customer)
    return unless user
    subscription = Stripe::Subscription.retrieve(session.subscription)
    activate_pro_subscription(user, subscription)
  end

  def handle_subscription_updated(subscription)
    # Could be Robin Pro or fan subscription
    if (fan_sub = FanSubscription.find_by(stripe_subscription_id: subscription.id))
      fan_sub.update!(
        status: subscription.status == "active" ? :active : :past_due,
        current_period_end: Time.at(subscription.current_period_end)
      )
    elsif (user = User.find_by(stripe_subscription_id: subscription.id))
      activate_pro_subscription(user, subscription)
    end
  end

  def handle_subscription_deleted(subscription)
    if (fan_sub = FanSubscription.find_by(stripe_subscription_id: subscription.id))
      fan_sub.update!(status: :cancelled)
    elsif (user = User.find_by(stripe_subscription_id: subscription.id))
      user.update!(
        plan: "free", subscription_status: "canceled",
        stripe_subscription_id: nil, subscription_current_period_end: nil
      )
    end
  end

  def handle_payment_failed(invoice)
    user = User.find_by(stripe_customer_id: invoice.customer)
    user&.update!(subscription_status: "past_due")
  end

  def activate_pro_subscription(user, subscription)
    price_id  = subscription.items.data.first&.price&.id
    plan_name = [ENV["STRIPE_PRO_MONTHLY_PRICE_ID"], ENV["STRIPE_PRO_YEARLY_PRICE_ID"]].include?(price_id) ? "pro" : "free"
    user.update!(
      plan: plan_name,
      subscription_status: subscription.status,
      stripe_subscription_id: subscription.id,
      subscription_current_period_end: Time.at(subscription.current_period_end)
    )
  end

  # --- Fan subscriptions ---

  def handle_fan_subscription_checkout(session)
    return unless session.mode == "subscription"
    fan_sub_id = session.metadata&.[]("fan_subscription_id")
    fan_sub = FanSubscription.find_by(id: fan_sub_id)
    return unless fan_sub

    stripe_sub = Stripe::Subscription.retrieve(session.subscription)
    fan_sub.update!(
      status: :active,
      stripe_subscription_id: stripe_sub.id,
      current_period_end: Time.at(stripe_sub.current_period_end)
    )
    fan_sub.creator_profile.increment!(:total_earned_cents,
      (fan_sub.amount_paid * (1 - CreatorProfile::PLATFORM_FEE_PERCENT / 100.0)).to_i)
  end

  # --- PPV purchases ---

  def handle_premium_purchase_checkout(session)
    return unless session.mode == "payment"
    purchase_id = session.metadata&.[]("premium_purchase_id")
    purchase = PremiumPurchase.find_by(id: purchase_id)
    return unless purchase

    purchase.update!(
      status: :completed,
      stripe_payment_intent_id: session.payment_intent
    )
    purchase.premium_post.increment!(:purchases_count)
    purchase.premium_post.creator_profile.increment!(:total_earned_cents, purchase.creator_earned)
  end
end
