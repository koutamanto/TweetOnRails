class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :set_unread_notifications_count, if: :user_signed_in?
  before_action :set_unread_messages_count, if: :user_signed_in?

  private

  def set_unread_notifications_count
    @unread_notifications_count = current_user.notifications.unread.count
  end

  def set_unread_messages_count
    @unread_messages_count = current_user.conversations
      .joins(:messages)
      .where(messages: { read_at: nil })
      .where.not(messages: { sender_id: current_user.id })
      .distinct.count
  end
end
