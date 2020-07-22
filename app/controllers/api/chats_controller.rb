class Api::ChatsController < Api::User::ApplicationController
  before_action :set_chat, only: [:show, :update, :destroy]

  include MergeImageParam

  # GET /api/chats
  def index
    @chats = Chat.all

    render json: @chats
  end

  # GET /api/chats/1
  def show
    render json: @chat
  end

  # POST /api/chats
  def create
    @chat = Chat.new(merge_first_row(chat_params, params[:images]).merge({
      user_id: current_user[:id],
      type: set_chat_type
      })
    )
    if @chat.save
      render json: @chat, status: :created
    else
      render json: @chat.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/chats/1
  def update
    if @chat.update(merge_first_row(chat_params, params[:images]))
      render json: @chat
    else
      render json: @chat.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/chats/1
  def destroy
    @chat.destroy
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_chat
    @chat = Chat.find(params[:id])
  end

  def set_chat_type
    if Chat::CHAT_TYPES.key?(params[:chat_type_id].to_i)
      Chat::CHAT_TYPES[params[:chat_type_id].to_i]
    else
      raise BadError.new("Chat type doesn't exist!")
    end
  end

  # Only allow a trusted parameter "white list" through.
  def chat_params
    params.permit(
      :message,
      :image_type,
      :image_path,
      :latitude,
      :longitude,
      :type,
      :chat_room_id,
      :user_id,
      :is_read
    )
  end
end
