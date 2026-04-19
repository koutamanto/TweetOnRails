class ExploreController < ApplicationController
  def index
    @tweets = Tweet.top_level.includes(:user, :likes).recent.page(params[:page]).per(20)
    @suggested_users = User.where.not(id: current_user.id)
                           .where.not(id: current_user.following)
                           .limit(5)
  end
end
