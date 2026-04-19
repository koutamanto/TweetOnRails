class SearchController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    if @query.present?
      term = "%#{@query}%"
      @tweets = Tweet.where("body LIKE ?", term).includes(:user).recent.page(params[:page]).per(20)
      @users = User.where("username LIKE ? OR display_name LIKE ?", term, term).limit(10)
    else
      @tweets = Tweet.none
      @users = User.none
    end
  end
end
