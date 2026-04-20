class SubscriptionsController < ApplicationController
  before_action :authenticate_user!, except: [:pricing]

  def pricing
  end

  def create
    price_id = params[:interval] == "year" ?
      ENV["STRIPE_PRO_YEARLY_PRICE_ID"] :
      ENV["STRIPE_PRO_MONTHLY_PRICE_ID"]

    customer = current_user.create_or_retrieve_stripe_customer!

    session = Stripe::Checkout::Session.create(
      customer: customer.id,
      mode: "subscription",
      line_items: [{ price: price_id, quantity: 1 }],
      success_url: success_subscriptions_url(session_id: "{CHECKOUT_SESSION_ID}"),
      cancel_url: pricing_url,
      allow_promotion_codes: true,
      subscription_data: {
        metadata: { user_id: current_user.id, type: "robin_pro" }
      },
      metadata: { type: "robin_pro", user_id: current_user.id.to_s }
    )

    redirect_to session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    redirect_to pricing_path, alert: "決済エラー: #{e.message}"
  end

  def success
    if params[:session_id].present?
      begin
        stripe_session = Stripe::Checkout::Session.retrieve(params[:session_id])
        if stripe_session.subscription.present?
          sub = Stripe::Subscription.retrieve(stripe_session.subscription)
          price_id = sub.items.data.first&.price&.id
          if [ENV["STRIPE_PRO_MONTHLY_PRICE_ID"], ENV["STRIPE_PRO_YEARLY_PRICE_ID"]].include?(price_id)
            current_user.update!(
              plan: "pro",
              subscription_status: sub.status,
              stripe_subscription_id: sub.id,
              stripe_customer_id: stripe_session.customer,
              subscription_current_period_end: Time.at(sub.current_period_end)
            )
          end
        end
      rescue Stripe::StripeError => e
        Rails.logger.error "Pro activation error: #{e.message}"
      end
    end
    redirect_to root_path, notice: "Robin Proへようこそ！すべてのプレミアム機能が有効になりました。"
  end

  def portal
    customer = current_user.create_or_retrieve_stripe_customer!
    session = Stripe::BillingPortal::Session.create(
      customer: customer.id,
      return_url: settings_billing_url
    )
    redirect_to session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    redirect_to settings_billing_path, alert: "ポータルエラー: #{e.message}"
  end
end
