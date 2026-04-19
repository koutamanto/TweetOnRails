class LikesController < ApplicationController
  before_action :set_tweet

  def create
    @like = current_user.likes.build(tweet: @tweet)
    @like.save
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("tweet_#{@tweet.id}_like", partial: "tweets/like_btn", locals: { tweet: @tweet.reload, current_user: current_user }) }
      format.html { redirect_back_or_to root_path }
    end
  end

  def destroy
    @like = current_user.likes.find_by(tweet: @tweet)
    @like&.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("tweet_#{@tweet.id}_like", partial: "tweets/like_btn", locals: { tweet: @tweet.reload, current_user: current_user }) }
      format.html { redirect_back_or_to root_path }
    end
  end

  private

  def set_tweet
    @tweet = Tweet.find(params[:tweet_id])
  end
end
