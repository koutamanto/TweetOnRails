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
        metadata: { user_id: current_user.id }
      }
    )

    redirect_to session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    redirect_to pricing_path, alert: "決済エラー: #{e.message}"
  end

  def success
    flash[:notice] = "🎉 Robin Proへようこそ！すべてのプレミアム機能が有効になりました。"
    redirect_to root_path
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
