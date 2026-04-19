class BookmarksController < ApplicationController
  before_action :set_tweet, only: [:create, :destroy]

  def index
    @tweets = current_user.bookmarked_tweets.order("bookmarks.created_at desc").page(params[:page]).per(20)
  end

  def create
    current_user.bookmarks.find_or_create_by(tweet: @tweet)
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("tweet_#{@tweet.id}_bookmark", partial: "tweets/bookmark_btn", locals: { tweet: @tweet.reload, current_user: current_user }) }
      format.html { redirect_back_or_to root_path }
    end
  end

  def destroy
    current_user.bookmarks.find_by(tweet: @tweet)&.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("tweet_#{@tweet.id}_bookmark", partial: "tweets/bookmark_btn", locals: { tweet: @tweet.reload, current_user: current_user }) }
      format.html { redirect_back_or_to root_path }
    end
  end

  private

  def set_tweet
    @tweet = Tweet.find(params[:tweet_id])
  end
end
