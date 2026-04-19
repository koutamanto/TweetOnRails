class Conversation < ApplicationRecord
  has_many :conversation_participants, dependent: :destroy
  has_many :participants, through: :conversation_participants, source: :user
  has_many :messages, -> { order(created_at: :asc) }, dependent: :destroy

  def self.between(user1, user2)
    joins(:conversation_participants)
      .where(conversation_participants: { user_id: user1.id })
      .where(id: ConversationParticipant.where(user_id: user2.id).select(:conversation_id))
      .first
  end

  def other_participant(current_user)
    participants.where.not(id: current_user.id).first
  end

  def last_message
    messages.last
  end

  def unread_count_for(user)
    messages.where.not(sender_id: user.id).where(read_at: nil).count
  end
end
