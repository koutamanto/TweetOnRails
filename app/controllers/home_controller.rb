class HomeController < ApplicationController
  before_action :authenticate_user!, only: [:new_tweets]

  def index
    @tweet = Tweet.new
    if user_signed_in?
      @tweets = current_user.timeline_tweets.page(params[:page]).per(20)
    else
      @tweets = Tweet.top_level.includes(:user, :likes, :original_tweet).recent.page(params[:page]).per(20)
    end
  end

  def new_tweets
    since = Time.parse(params[:since]) rescue 1.minute.ago
    @tweets = current_user.timeline_tweets
      .where("tweets.created_at > ?", since)
      .order(created_at: :desc)
    respond_to do |format|
      format.turbo_stream
    end
  end
end
