class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: "User"

  validates :body, presence: true

  def read_by!(user)
    update(read_at: Time.current) if sender != user && read_at.nil?
  end

  def broadcast_to_channel
    ConversationChannel.broadcast_to(
      conversation,
      { html: ApplicationController.render(partial: "messages/message", locals: { message: self }) }
    )
  end
end
