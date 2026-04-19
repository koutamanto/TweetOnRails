class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = current_user.conversations.find_by(id: params[:conversation_id])
    if conversation
      stream_for conversation
    else
      reject
    end
  end
end
