class UsersController < ApplicationController
  before_action :set_user

  def show
    @tweets = @user.tweets.top_level.includes(:user, :likes, :original_tweet).recent.page(params[:page]).per(20)
  end

  def followers
    @users = @user.followers.page(params[:page]).per(20)
  end

  def following
    @users = @user.following.page(params[:page]).per(20)
  end

  def media
    @tweets = @user.tweets.joins(:media_attachments).distinct.recent.page(params[:page]).per(20)
  end

  def likes
    @tweets = @user.liked_tweets.includes(:user).recent.page(params[:page]).per(20)
  end

  private

  def set_user
    @user = User.find_by!(username: params[:username])
  end
end
