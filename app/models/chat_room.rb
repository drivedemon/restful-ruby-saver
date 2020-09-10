class ChatRoom < ApplicationRecord
  CHAT_ROOM_TOPIC = I18n.t("notification_mobile.join_private_conversation")

  acts_as_paranoid

  after_commit :create_start_conversation_to_chat_room, :push_notify_to_user, on: [:create, :update]
  belongs_to :help_request, -> { with_deleted }
  belongs_to :offer_request, -> { with_deleted }
  has_many :chats
  has_many :notifications

  delegate :user, to: :help_request, prefix: true

  include NotificationFcmFormat

  validates :help_request_id, presence: true, numericality: true

  def as_chat_room_format(current_user)
    self.slice(:id).merge(
      {
        help_request: help_request.as_help_request_format(current_user),
        offer_request: offer_request.as_self_user_format,
        chats: chats.map{ |e| e.as_chat_format(current_user) }.compact
      }
    )
  end

  def as_only_chat_format(current_user = nil)
    self.slice(:id).merge(
      {
        chats: chats.map{ |e| e.as_chat_format(current_user) }.compact
      }
    )
  end

  def create_start_conversation_to_chat_room
    chat = chats.create(
      type: StartChat::MESSAGE,
      user_id: help_request.user_id,
      is_read: true
    )
    create_notify_history(id, chat.id, offer_request.user_id)
    create_initial_message_from_offer(offer_request.description, offer_request.user_id) if offer_request.description.present?
  end

  def push_notify_to_user
    FcmNotification.push_notification(CHAT_ROOM_TOPIC, nil, nil, offer_request.user, as_fcm_notification_format) if offer_request.user.notification_status
  end

  def self.notify_pusher_conversation(chat_user_id, chat_count)
    Pusher.trigger("user-#{chat_user_id}", "remove-conversation", chat_count)
  end

  def self.notify_pusher_available_chat(help_request_user_id)
    Pusher.trigger("user-#{help_request_user_id}", "connected-chat", nil)
  end

  private

  def create_initial_message_from_offer(description, offer_user_id)
    chats.create(
      message: description,
      type: GeneralChat::MESSAGE,
      user_id: offer_user_id,
      is_read: true
    )
  end

  def create_notify_history(id, chat_id, offer_user_id)
    Notification.create(chat_room_id: id, chat_id: chat_id, user_id: offer_user_id)
  end
end
