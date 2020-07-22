class ChatRoom < ApplicationRecord
  @@chat_room_topic = 'You can join a private conversation!'

  acts_as_paranoid

  after_save :create_start_conversation_to_chat_room, :create_notify_history, :push_notify_to_user
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
    chats.create(
      type: StartChat::MESSAGE,
      user_id: help_request.user_id,
      is_read: true
    )
    create_initial_message_from_offer(offer_request.description, offer_request.user_id) if offer_request.description.present?
  end

  def create_notify_history
    Notification.create(chat_room_id: self.id, chat_id: chats.first.id, user_id: offer_request.user_id)
  end

  def push_notify_to_user
    FcmNotification.push_notification(@@chat_room_topic, nil, nil, offer_request.user, as_fcm_notification_format) if offer_request.user.notification_status
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
end
