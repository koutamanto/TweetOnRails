class TweetsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :destroy, :retweet, :unretweet]
  before_action :set_tweet, only: [:show, :destroy, :retweet, :unretweet]

  def show
    @replies = @tweet.replies.includes(:user).order(created_at: :asc)
    @reply = Tweet.new
  end

  def create
    @tweet = current_user.tweets.build(tweet_params)
    if @tweet.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to root_path }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("tweet_form", partial: "shared/compose", locals: { tweet: @tweet }) }
        format.html { redirect_to root_path, alert: @tweet.errors.full_messages.join(", ") }
      end
    end
  end

  def destroy
    if @tweet.user == current_user
      @tweet.destroy
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove("tweet_#{@tweet.id}") }
        format.html { redirect_back_or_to root_path, notice: "ツイートを削除しました" }
      end
    else
      redirect_back_or_to root_path, alert: "権限がありません"
    end
  end

  def retweet
    existing = current_user.tweets.find_by(original_tweet_id: @tweet.id)
    if existing
      head :unprocessable_entity
    else
      rt = current_user.tweets.create(original_tweet_id: @tweet.id, body: nil)
      if rt.persisted?
        Notification.create(user: @tweet.user, actor: current_user, action: :retweeted, notifiable: @tweet) unless @tweet.user == current_user
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace("tweet_#{@tweet.id}_retweet", partial: "tweets/retweet_btn", locals: { tweet: @tweet.reload, current_user: current_user }) }
          format.html { redirect_back_or_to root_path }
        end
      end
    end
  end

  def unretweet
    rt = current_user.tweets.find_by(original_tweet_id: @tweet.id)
    rt&.destroy
    Notification.where(user: @tweet.user, actor: current_user, action: :retweeted).destroy_all
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("tweet_#{@tweet.id}_retweet", partial: "tweets/retweet_btn", locals: { tweet: @tweet.reload, current_user: current_user }) }
      format.html { redirect_back_or_to root_path }
    end
  end

  private

  def set_tweet
    @tweet = Tweet.find(params[:id])
  end

  def tweet_params
    params.require(:tweet).permit(:body, media: [])
  end
end
