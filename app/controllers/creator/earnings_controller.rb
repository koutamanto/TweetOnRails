class Creator::EarningsController < Creator::BaseController
  before_action :require_creator!

  def show
    @creator_profile    = my_creator_profile
    @subscriber_count   = @creator_profile.fan_subscriptions.active.count
    @total_earned       = @creator_profile.total_earned_cents
    @monthly_revenue    = @creator_profile.fan_subscriptions.active.sum(:amount_paid)
    @fan_subscriptions  = @creator_profile.fan_subscriptions.active
                            .order(created_at: :desc).includes(:subscriber)
    @recent_purchases   = PremiumPurchase.completed
                            .joins(:premium_post)
                            .where(premium_posts: { creator_profile_id: @creator_profile.id })
                            .order(created_at: :desc).limit(30)
                            .includes(:buyer, :premium_post)
  end
end
