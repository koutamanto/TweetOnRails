class FanSubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def create
    creator_profile = CreatorProfile.find(params[:creator_profile_id])

    if creator_profile.user == current_user
      return redirect_back fallback_location: root_path, alert: "自分のコンテンツにはサブスクできません"
    end
    unless creator_profile.has_subscription_plan?
      return redirect_back fallback_location: root_path, alert: "このクリエイターはサブスクリプションを設定していません"
    end
    unless creator_profile.payout_enabled?
      return redirect_back fallback_location: root_path, alert: "このクリエイターはまだ支払い設定を完了していません"
    end

    fan_sub = FanSubscription.find_or_initialize_by(subscriber: current_user, creator_profile: creator_profile)
    if fan_sub.persisted? && (fan_sub.active? || fan_sub.pending?)
      return redirect_back fallback_location: root_path, alert: "すでにサブスクリプション登録済みです"
    end

    fan_sub.assign_attributes(status: :pending, amount_paid: creator_profile.subscription_price)
    fan_sub.save!

    customer = current_user.create_or_retrieve_stripe_customer!

    session = Stripe::Checkout::Session.create(
      customer: customer.id,
      mode: "subscription",
      line_items: [{
        price_data: {
          currency: "jpy",
          product_data: { name: "#{creator_profile.user.display_name} をサポート" },
          unit_amount: creator_profile.subscription_price,
          recurring: { interval: "month" }
        },
        quantity: 1
      }],
      subscription_data: {
        application_fee_percent: CreatorProfile::PLATFORM_FEE_PERCENT,
        transfer_data: { destination: creator_profile.stripe_account_id },
        metadata: { type: "fan_subscription", fan_subscription_id: fan_sub.id.to_s }
      },
      metadata: { type: "fan_subscription", fan_subscription_id: fan_sub.id.to_s },
      success_url: success_fan_subscriptions_url(fan_subscription_id: fan_sub.id),
      cancel_url: creator_profile_url(creator_profile.user.username)
    )

    fan_sub.update_column(:stripe_checkout_session_id, session.id)
    redirect_to session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    fan_sub.destroy if fan_sub&.persisted? && fan_sub.pending?
    redirect_back fallback_location: root_path, alert: "決済エラー: #{e.message}"
  end

  def success
    fan_sub = FanSubscription.find_by(id: params[:fan_subscription_id])
    if fan_sub&.subscriber == current_user
      redirect_to creator_profile_path(fan_sub.creator_profile.user.username),
                  notice: "サブスクリプションを開始しました！素晴らしいクリエイターを応援しましょう。"
    else
      redirect_to root_path
    end
  end

  def destroy
    fan_sub = FanSubscription.find_by(id: params[:id], subscriber: current_user)
    return redirect_back fallback_location: root_path, alert: "見つかりませんでした" unless fan_sub

    if fan_sub.stripe_subscription_id.present?
      Stripe::Subscription.cancel(fan_sub.stripe_subscription_id)
    end
    fan_sub.update!(status: :cancelled)
    redirect_back fallback_location: root_path, notice: "サブスクリプションをキャンセルしました"
  rescue Stripe::StripeError => e
    redirect_back fallback_location: root_path, alert: "キャンセルエラー: #{e.message}"
  end
end
