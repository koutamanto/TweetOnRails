class AiContentController < ApplicationController
  def context
    @version        = (params[:version] || "1").to_s.gsub(/[^0-9a-z\-]/i, "")
    @user_count     = User.count
    @tweet_count    = Tweet.top_level.count
    @creator_count  = CreatorProfile.count rescue 0
    @like_count     = Like.count rescue 0
    @generated_at   = Time.current
    @generated_iso  = @generated_at.iso8601
    @generated_jp   = @generated_at.strftime("%Y年%m月%d日 %H:%M:%S JST")
    @data_date      = @generated_at.strftime("%Y-%m-%d")
    @latest_tweet   = Tweet.top_level.order(created_at: :desc).first
  end

  def llms
    @version = (params[:v] || "1").to_s
    render "llms", formats: [:text], layout: false, content_type: "text/plain"
  end
end
