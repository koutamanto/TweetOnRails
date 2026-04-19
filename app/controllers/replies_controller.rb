class RepliesController < ApplicationController
  before_action :set_tweet

  def create
    @reply = current_user.tweets.build(reply_params.merge(parent_tweet_id: @tweet.id))
    if @reply.save
      redirect_to tweet_path(@tweet), notice: "返信しました"
    else
      redirect_to tweet_path(@tweet), alert: @reply.errors.full_messages.join(", ")
    end
  end

  private

  def set_tweet
    @tweet = Tweet.find(params[:tweet_id])
  end

  def reply_params
    params.require(:tweet).permit(:body, media: [])
  end
end
