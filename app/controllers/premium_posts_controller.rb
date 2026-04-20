class PremiumPostsController < ApplicationController
  def show
    @post            = PremiumPost.find(params[:id])
    @creator_profile = @post.creator_profile
    @creator         = @creator_profile.user

    unless @post.published? || (user_signed_in? && @creator == current_user)
      redirect_to creator_profile_path(@creator.username), alert: "この投稿は存在しません"
      return
    end

    @can_access    = @post.accessible_by?(current_user)
    @is_subscribed = user_signed_in? && FanSubscription.active_access.exists?(
                       subscriber: current_user, creator_profile: @creator_profile)
    @has_purchased = @post.purchased_by?(current_user)
    @my_subscription = user_signed_in? ? @creator_profile.fan_subscriptions.find_by(subscriber: current_user) : nil

    @post.increment!(:views_count) if @can_access && user_signed_in? && @creator != current_user
  end
end
