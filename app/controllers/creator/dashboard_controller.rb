class Creator::DashboardController < Creator::BaseController
  before_action :require_creator!

  def show
    @creator_profile   = my_creator_profile
    @recent_posts      = @creator_profile.premium_posts.published.limit(5)
    @draft_posts       = @creator_profile.premium_posts.drafts.limit(3)
    @subscriber_count  = @creator_profile.fan_subscriptions.active.count
    @total_earned      = @creator_profile.total_earned_cents
    @published_count   = @creator_profile.premium_posts.published.count
    @recent_subscribers = @creator_profile.fan_subscriptions.active
                            .order(created_at: :desc).limit(5).includes(:subscriber)
    @recent_purchases  = PremiumPurchase.completed
                           .joins(:premium_post)
                           .where(premium_posts: { creator_profile_id: @creator_profile.id })
                           .order(created_at: :desc).limit(5)
                           .includes(:buyer, :premium_post)
  end
end
