class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: "User"

  validates :body, presence: true

  def read_by!(user)
    update(read_at: Time.current) if sender != user && read_at.nil?
  end

  def broadcast_to_channel
    html = ApplicationController.render(
      partial: "messages/message",
      locals: { message: self, current_user: nil }
    )
    ConversationChannel.broadcast_to(conversation, { html: html, sender_id: sender_id })
  end

  after_create_commit :push_dm_badge_to_recipient

  private

  def push_dm_badge_to_recipient
    other = conversation.participants.where.not(id: sender_id).first
    return unless other

    unread = Message
      .joins(conversation: :conversation_participants)
      .where(conversation_participants: { user_id: other.id })
      .where.not(sender_id: other.id)
      .where(read_at: nil)
      .count
    UserChannel.broadcast_to(other, { type: "dm_count", count: unread })

    WebPushService.deliver(
      user:  other,
      title: "#{sender.display_name}からメッセージ",
      body:  body.truncate(100),
      url:   "/conversations/#{conversation_id}",
      tag:   "dm-#{conversation_id}"
    )
  end
end
