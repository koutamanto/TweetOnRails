class PremiumPurchasesController < ApplicationController
  before_action :authenticate_user!

  def create
    post             = PremiumPost.find(params[:premium_post_id])
    creator_profile  = post.creator_profile

    return redirect_back fallback_location: root_path, alert: "自分のコンテンツは購入できません" if creator_profile.user == current_user
    return redirect_back fallback_location: root_path, alert: "この投稿は有料コンテンツではありません" unless post.ppv?
    return redirect_back fallback_location: root_path, alert: "すでに購入済みです" if post.purchased_by?(current_user)
    unless creator_profile.payout_enabled?
      return redirect_back fallback_location: root_path, alert: "このクリエイターはまだ支払い設定を完了していません"
    end

    platform_fee   = (post.price * CreatorProfile::PLATFORM_FEE_PERCENT / 100.0).ceil
    creator_earned = post.price - platform_fee

    purchase = PremiumPurchase.create!(
      buyer: current_user, premium_post: post,
      amount_paid: post.price, platform_fee: platform_fee,
      creator_earned: creator_earned, status: :pending
    )

    customer = current_user.create_or_retrieve_stripe_customer!

    session = Stripe::Checkout::Session.create(
      customer: customer.id,
      mode: "payment",
      line_items: [{
        price_data: {
          currency: "jpy",
          product_data: { name: post.title },
          unit_amount: post.price
        },
        quantity: 1
      }],
      payment_intent_data: {
        application_fee_amount: platform_fee,
        transfer_data: { destination: creator_profile.stripe_account_id }
      },
      metadata: { type: "premium_purchase", premium_purchase_id: purchase.id.to_s },
      success_url: premium_purchase_success_url(purchase_id: purchase.id),
      cancel_url:  premium_post_url(post)
    )

    purchase.update_column(:stripe_checkout_session_id, session.id)
    redirect_to session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    purchase&.destroy
    redirect_back fallback_location: root_path, alert: "決済エラー: #{e.message}"
  end

  def success
    purchase = PremiumPurchase.find_by(id: params[:purchase_id])
    if purchase&.buyer == current_user
      redirect_to premium_post_path(purchase.premium_post), notice: "購入が完了しました！コンテンツをお楽しみください。"
    else
      redirect_to root_path
    end
  end
end
