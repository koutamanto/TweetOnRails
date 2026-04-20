class Creator::BaseController < ApplicationController
  before_action :authenticate_user!

  private

  def my_creator_profile
    @my_creator_profile ||= current_user.creator_profile
  end
  helper_method :my_creator_profile

  def require_creator!
    redirect_to creator_setup_path unless my_creator_profile
  end
end
