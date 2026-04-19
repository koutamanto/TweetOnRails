class ConversationsController < ApplicationController
  def index
    @conversations = current_user.conversations.includes(:participants, :messages)
                                 .order(updated_at: :desc)
  end

  def show
    @conversation = current_user.conversations.find(params[:id])
    @messages = @conversation.messages.includes(:sender)
    @messages.each { |m| m.read_by!(current_user) }
    @message = Message.new
  end

  def create
    recipient = User.find(params[:recipient_id])
    @conversation = Conversation.between(current_user, recipient)

    unless @conversation
      @conversation = Conversation.create!
      @conversation.participants << current_user
      @conversation.participants << recipient
    end

    redirect_to conversation_path(@conversation)
  end
end
