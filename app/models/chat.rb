class Chat < ApplicationRecord
  CHAT_TOPIC = I18n.t("notification_mobile.you_got_message")

  CHAT_TYPES = {
    1 => "GeneralChat",
    2 => "StartChat",
    3 => "AcceptChat",
    4 => "ConfirmChat",
    5 => "RejectChat",
    6 => "StopLocationChat"
  }.freeze

  acts_as_paranoid

  default_scope { order(id: :asc) }

  after_commit :notify_pusher, :push_notify_to_user, on: [:create, :update]
  belongs_to :chat_room
  belongs_to :user
  has_many :notifications

  include ApplyReadAll
  include NotificationFcmFormat

  def as_chat_format(current_user = nil)
    self.slice(:id, :message, :latitude, :longitude, :type, :type_id, :image_path, :is_read).merge(
      {
        created_at_default: created_at,
        created_at: TimeToHumanWord.calculator_time_to_human_word(created_at),
        is_message_owner: current_user.present? ? user.id == current_user.id : nil,
        is_request_owner: user.id == chat_room.help_request.user.id,
        user: user&.as_profile_json
      }
    )
  end

  def notify_pusher
    Pusher.trigger("chatroom-#{chat_room_id}", "chats-message", as_chat_format)
    pusher_trigger_conversation("complete-request", nil) if check_type_id?(:complete)
    pusher_trigger_conversation("start-conversation", custom_data_pusher) if check_type_id?(:start)
    Pusher.trigger("user-#{set_opposite_user}", define_pusher_name, set_count_chat) if check_type_id?(:general)
  end

  def push_notify_to_user
    return if Chat.where(chat_room_id: chat_room, type: Chat::CHAT_TYPES[1]).count == 1
    FcmNotification.push_notification(CHAT_TOPIC, message, image_path, user, as_fcm_notification_format) if user.notification_status
  end

  private

  def custom_data_pusher
    {
      chat_room_id: chat_room_id,
      help_request_id: chat_room.help_request.id,
      offer_request_user: chat_room.offer_request.user_id
    }
  end

  def pusher_trigger_conversation(event_name, data = nil)
    Pusher.trigger("helprequest-#{chat_room.help_request.id}", event_name, data)
  end

  def check_is_owner_chat?
    user_id == chat_room.help_request.user_id
  end

  def set_opposite_user
    check_is_owner_chat? ? chat_room.offer_request.user_id : chat_room.help_request.user_id
  end

  def check_type_id?(type_message)
    case type_message
    when :general
      type == GeneralChat::MESSAGE
    when :start
      type == StartChat::MESSAGE
    when :complete
      type == ConfirmChat::MESSAGE
    end
  end

  def define_pusher_name
    is_read ? "remove-conversation" : "receive-conversation"
  end

  def set_count_chat
    is_read ? 1 : nil
  end
end
