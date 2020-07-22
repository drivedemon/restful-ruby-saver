class Api::ChatRoomsController < Api::User::ApplicationController
  before_action :set_chat, only: [:show]
  before_action :set_chat_within_chat_room_show, only: [:show]
  before_action :push_notify_conversation, only: [:show]
  before_action :update_chat_status, only: [:show]

  def create
    @chat_room = ChatRoom.new(help_request_id: params[:help_request_id], offer_request_id: params[:offer_request_id])

    if @chat_room.save
      render json: @chat_room, status: :created
    else
      render json: @chat_room.errors, status: :unprocessable_entity
    end
  end

  def show
    render json: @chat_room
  end

  private
  def set_chat
    @chats = Chat.where(:chat_room_id => params[:id], :is_read => false)
  end

  def set_chat_within_chat_room_show
    @chat_room = ChatRoom.find(params[:id])&.as_chat_room_format(current_user)
  end

  def push_notify_conversation
    return unless check_opposite_user?
    force_user = current_user.id == @chat_room[:help_request][:user][:id] ? @chat_room[:offer_request][:user][:id] : @chat_room[:help_request][:user][:id]
    ChatRoom.notify_pusher_conversation(current_user.id, @chats.count)
    ChatRoom.notify_pusher_available_chat(force_user)
  end

  def update_chat_status
    @chats.update_all(is_read: true) if check_opposite_user?
  end

  def check_opposite_user?
    @chats.present? && @chats.last&.user_id != current_user.id
  end
end
