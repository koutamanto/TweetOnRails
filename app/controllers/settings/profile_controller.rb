class Settings::ProfileController < ApplicationController
  def profile
    @user = current_user
  end

  def update_profile
    @user = current_user
    if @user.update(profile_params)
      redirect_to settings_profile_path, notice: "プロフィールを更新しました"
    else
      render :profile, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:display_name, :bio, :location, :website, :avatar, :header_image)
  end
end
