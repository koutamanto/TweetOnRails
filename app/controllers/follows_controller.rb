class FollowsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_target_user

  def create
    current_user.follows.find_or_create_by(following: @target_user)
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("follow_btn_#{@target_user.id}", partial: "users/follow_btn", locals: { user: @target_user, current_user: current_user }) }
      format.html { redirect_back_or_to user_path(@target_user.username) }
    end
  end

  def destroy
    current_user.follows.find_by(following: @target_user)&.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace("follow_btn_#{@target_user.id}", partial: "users/follow_btn", locals: { user: @target_user, current_user: current_user }) }
      format.html { redirect_back_or_to user_path(@target_user.username) }
    end
  end

  private

  def set_target_user
    @target_user = User.find(params[:id])
  end
end
