module Subscribable
  extend ActiveSupport::Concern

  PLANS = {
    "free"    => { tweet_limit: 280, bio_limit: 160 },
    "pro"     => { tweet_limit: 500, bio_limit: 320 }
  }.freeze

  included do
    validates :plan, inclusion: { in: PLANS.keys }
  end

  def pro?
    plan == "pro" && subscription_active?
  end

  def subscription_active?
    subscription_status == "active" ||
      (subscription_current_period_end.present? && subscription_current_period_end > Time.current)
  end

  def tweet_char_limit
    pro? ? PLANS["pro"][:tweet_limit] : PLANS["free"][:tweet_limit]
  end

  def bio_char_limit
    pro? ? PLANS["pro"][:bio_limit] : PLANS["free"][:bio_limit]
  end

  # Always creates a fresh customer whose email matches this user.
  # If a saved customer_id exists but belongs to a different email in Stripe,
  # we clear it and create a new one to avoid cross-account contamination.
  def create_or_retrieve_stripe_customer!
    if stripe_customer_id.present?
      begin
        customer = Stripe::Customer.retrieve(stripe_customer_id)
        # If the customer was deleted or has a different email, recreate it
        if customer.deleted? || customer.email != email
          update_column(:stripe_customer_id, nil)
          return create_or_retrieve_stripe_customer!
        end
        customer
      rescue Stripe::InvalidRequestError
        # Customer doesn't exist in Stripe anymore — clear and recreate
        update_column(:stripe_customer_id, nil)
        create_or_retrieve_stripe_customer!
      end
    else
      customer = Stripe::Customer.create(
        email: email,
        name: display_name,
        metadata: { user_id: id.to_s, username: username }
      )
      update_column(:stripe_customer_id, customer.id)
      customer
    end
  end
end
