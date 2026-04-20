class ConversationsController < ApplicationController
  before_action :authenticate_user!

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
    recipient = User.find_by!(id: params[:recipient_id])

    if recipient == current_user
      redirect_to conversations_path, alert: "自分自身にはメッセージを送れません"
      return
    end

    @conversation = Conversation.between(current_user, recipient)

    unless @conversation
      @conversation = Conversation.create!
      @conversation.participants << current_user
      @conversation.participants << recipient
    end

    redirect_to conversation_path(@conversation)
  end
end
