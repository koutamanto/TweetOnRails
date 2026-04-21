class CreatorProfile < ApplicationRecord
  PLATFORM_FEE_PERCENT = 5

  belongs_to :user
  has_many :premium_posts,   dependent: :destroy
  has_many :fan_subscriptions, dependent: :destroy
  has_one_attached :cover_image

  validates :subscription_price, numericality: { greater_than_or_equal_to: 0 }
  validates :tagline, length: { maximum: 200 }

  def payout_enabled?
    stripe_onboarded? && stripe_account_id.present?
  end

  def has_subscription_plan?
    subscription_price > 0 && accepting_subscribers?
  end

  def active_subscriber_count
    fan_subscriptions.active.count
  end

  def create_stripe_account!
    return stripe_account_id if stripe_account_id.present?
    account = Stripe::Account.create(
      type: "express",
      country: "JP",
      capabilities: {
        card_payments: { requested: true },
        transfers:     { requested: true }
      }
    )
    update!(stripe_account_id: account.id)
    account.id
  end

  def onboarding_url(refresh_url:, return_url:)
    create_stripe_account! unless stripe_account_id.present?
    ensure_card_payments_capability!
    link = Stripe::AccountLink.create(
      account: stripe_account_id,
      refresh_url: refresh_url,
      return_url: return_url,
      type: "account_onboarding"
    )
    link.url
  end

  def stripe_dashboard_url
    return nil unless payout_enabled?
    Stripe::Account.create_login_link(stripe_account_id).url
  end

  private

  def ensure_card_payments_capability!
    return unless stripe_account_id.present?
    account = Stripe::Account.retrieve(stripe_account_id)
    return if account.capabilities&.card_payments.present?
    Stripe::Account.update(stripe_account_id,
      capabilities: { card_payments: { requested: true }, transfers: { requested: true } })
  rescue Stripe::StripeError => e
    Rails.logger.warn "[Stripe] ensure_card_payments_capability! failed for account=#{stripe_account_id}: #{e.message}"
    # Non-fatal — onboarding link creation continues
  end
end
