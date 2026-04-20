class PushSubscriptionsController < ApplicationController
  def create
    sub = current_user.push_subscriptions.find_or_initialize_by(endpoint: params[:endpoint])
    sub.assign_attributes(p256dh: params[:p256dh], auth: params[:auth])
    sub.save!
    head :created
  rescue => e
    Rails.logger.error "[PushSub] #{e.message}"
    head :unprocessable_entity
  end

  def destroy
    current_user.push_subscriptions.find_by(endpoint: params[:endpoint])&.destroy
    head :ok
  end
end
