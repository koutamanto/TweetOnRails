class HomeController < ApplicationController
  def index
    @tweet = Tweet.new
    @tweets = current_user.timeline_tweets.page(params[:page]).per(20)
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
