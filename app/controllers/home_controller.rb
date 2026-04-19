class HomeController < ApplicationController
  def index
    @tweet = Tweet.new
    @tweets = current_user.timeline_tweets.page(params[:page]).per(20)
  end
end
