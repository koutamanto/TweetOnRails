class SitemapsController < ApplicationController
  def index
    @users = User.select(:username, :updated_at).order(updated_at: :desc).limit(5000)
    @tweets = Tweet.top_level.select(:id, :updated_at).order(updated_at: :desc).limit(5000)
    @creator_profiles = CreatorProfile.joins(:user).select("users.username, creator_profiles.updated_at").order("creator_profiles.updated_at DESC").limit(1000)

    respond_to do |format|
      format.xml { render layout: false }
    end
  end
end
