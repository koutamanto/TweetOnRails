class CreatorProfilesController < ApplicationController
  def show
    user = User.find_by!(username: params[:username])
    @creator_profile = user.creator_profile
    return redirect_to user_path(params[:username]), alert: "このユーザーはクリエイターではありません" unless @creator_profile
    @creator           = user
    @posts             = @creator_profile.premium_posts.published
    @is_subscribed     = user_signed_in? && FanSubscription.active_access.exists?(
                           subscriber: current_user, creator_profile: @creator_profile)
    @my_subscription   = user_signed_in? ? @creator_profile.fan_subscriptions.find_by(subscriber: current_user) : nil
    @subscriber_count  = @creator_profile.fan_subscriptions.active.count
  end
end
