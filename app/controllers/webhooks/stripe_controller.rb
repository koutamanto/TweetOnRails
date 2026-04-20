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
    return unless session.mode == "subscription"
    user = User.find_by(stripe_customer_id: session.customer)
    return unless user
    subscription = Stripe::Subscription.retrieve(session.subscription)
    activate_subscription(user, subscription)
  end

  def handle_subscription_updated(subscription)
    user = User.find_by(stripe_subscription_id: subscription.id)
    return unless user
    activate_subscription(user, subscription)
  end

  def handle_subscription_deleted(subscription)
    user = User.find_by(stripe_subscription_id: subscription.id)
    return unless user
    user.update!(
      plan: "free",
      subscription_status: "canceled",
      stripe_subscription_id: nil,
      subscription_current_period_end: nil
    )
  end

  def handle_payment_failed(invoice)
    user = User.find_by(stripe_customer_id: invoice.customer)
    return unless user
    user.update!(subscription_status: "past_due")
  end

  def activate_subscription(user, subscription)
    price_id   = subscription.items.data.first&.price&.id
    plan_name  = [ENV["STRIPE_PRO_MONTHLY_PRICE_ID"], ENV["STRIPE_PRO_YEARLY_PRICE_ID"]].include?(price_id) ? "pro" : "free"
    user.update!(
      plan: plan_name,
      subscription_status: subscription.status,
      stripe_subscription_id: subscription.id,
      subscription_current_period_end: Time.at(subscription.current_period_end)
    )
  end
end
