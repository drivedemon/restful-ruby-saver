class OfferRequest < ApplicationRecord
  OFFER_REQUEST_TOPIC = 'Someone offers to help you!'.freeze
  ACCEPT_REQUEST_TOPIC = '%s accepted on your offer'.freeze
  ACCEPT_OFFER_TOPIC = '%s confirmed to help on your request'.freeze
  COMPLETE_REQUEST_TOPIC = '%s marked your offer as completed'.freeze
  COMPLETE_OFFER_TOPIC = '%s marked your request as completed'.freeze
  REJECT_OFFER_TOPIC = 'The Requester has chosen to accept help from another Helper'.freeze
  REJECT_OFFER_DESCRIPTION = 'This request is no longer open to offers of help'.freeze
  CANCEL_ACCEPT_HELPEE_TOPIC = 'You rejected your accept confirmed from %s'.freeze
  CANCEL_ACCEPT_OFFER_TOPIC = 'You cancelled to accept help from %s'.freeze

  PENDING_STATUS = 1
  CONFIRM_STATUS = 2
  COMPLETE_STATUS = 3
  REJECT_STATUS = 4

  acts_as_paranoid

  default_scope { order(created_at: :desc) }

  after_create :create_notify_history, :notify_pusher
  after_destroy :create_reject_message, :push_notify_after_reject, :notify_pusher
  before_destroy :create_notify_history_after_reject
  after_save :push_notify_to_user
  belongs_to :helpee_request_status
  belongs_to :helper_request_status
  belongs_to :help_request
  belongs_to :owned_help_request, -> { with_deleted }, class_name: 'HelpRequest', foreign_key: "help_request_id", optional: true
  belongs_to :user
  has_one :chat_room
  has_many :notifications
  has_many :rates

  delegate :user, to: :owned_help_request, prefix: true

  include NotificationFcmFormat

  scope :with_complete_status, -> { where(helper_request_status_id: [COMPLETE_STATUS, REJECT_STATUS]) }
  scope :with_current_user, -> { where(user_id: current_user) }
  scope :with_pending_status, -> (status) { where(helpee_request_status_id: status) }
  scope :without_pending_status, -> { where.not(helper_request_status_id: PENDING_STATUS) }
  scope :without_confirm_status, -> (offer_request) { where(help_request_id: offer_request.help_request_id).where.not(user_id: offer_request.user_id).with_deleted }
  scope :without_complete_status, -> { where.not(helper_request_status_id: [COMPLETE_STATUS, REJECT_STATUS]) }

  validates :help_request_id, presence: true, numericality: true

  def as_offer_request_format(current_user, display_deleted_offer = false)
    self.slice(:id, :description, :helpee_request_status_id, :helper_request_status_id, :rates).merge(
      {
        created_at: TimeToHumanWord.calculator_time_to_human_word(created_at),
        help_request: display_deleted_offer ? owned_help_request&.as_help_request_format(current_user) : help_request&.as_help_request_format(current_user),
        chat_room: chat_room&.as_only_chat_format(current_user),
        distance: DistanceCalc.coordinate_distance_calculator(help_request&.latitude || 0, help_request&.longitude || 0, latitude || 0, longitude || 0),
        user: user&.as_profile_json
      }
    )
  end

  def as_self_user_format(current_user = nil)
    self.slice(:id, :chat_room, :description, :helpee_request_status_id, :helper_request_status_id).merge(
      {
        help_request: current_user.present? ? help_request&.as_help_request_format(current_user) : help_request,
        user: user&.as_profile_json
      }
    )
  end

  def create_notify_history
    notifications.create(user_id: owned_help_request_user.id)
  end

  def self.create_notify_history(chat, user)
    Notification.create(chat_room_id: chat.chat_room.id, chat_id: chat.id, user_id: user.id)
  end

  def create_notify_history_after_reject
    notifications.create(user_id: user.id)
  end

  def create_reject_message
    Chat.create(type: RejectChat::MESSAGE, chat_room_id: chat_room.id, user_id: help_request.user_id) if chat_room.present?
  end

  def push_notify_to_user
    force_topic = define_topic_notification(saved_change_to_helpee_request_status_id, saved_change_to_helper_request_status_id)
    FcmNotification.push_notification(force_topic % get_owner_user, description, nil, get_owner_user, as_fcm_notification_format) if get_owner_user.notification_status
  end

  def push_notify_after_reject
    FcmNotification.push_notification(REJECT_OFFER_TOPIC, REJECT_OFFER_DESCRIPTION, nil, user, as_fcm_notification_format) if user.notification_status
  end

  private
  
  def define_topic_notification(changed_helpee_status_id, changed_helper_status_id)
    return OFFER_REQUEST_TOPIC if changed_helpee_status_id.blank? && changed_helper_status_id.blank?
    # helpee section
    if changed_helpee_status_id.present?
      if changed_helpee_status_id[1] == PENDING_STATUS # cancel self accept
        CANCEL_ACCEPT_OFFER_TOPIC
      elsif changed_helpee_status_id[1] == CONFIRM_STATUS
        ACCEPT_REQUEST_TOPIC
      elsif changed_helpee_status_id[1] == COMPLETE_STATUS
        COMPLETE_REQUEST_TOPIC
      end
    end
    # helper section
    if changed_helper_status_id.present?
      if changed_helper_status_id[1] == CONFIRM_STATUS
        ACCEPT_OFFER_TOPIC
      elsif changed_helper_status_id[1] == COMPLETE_STATUS
        COMPLETE_OFFER_TOPIC
      elsif changed_helper_status_id[1] == REJECT_STATUS # cancel accept from helper
        CANCEL_ACCEPT_HELPEE_TOPIC
      end
    end
  end

  def get_owner_user
    saved_change_to_helpee_request_status_id.present? ? user : owned_help_request_user
  end

  def define_pusher_name
    deleted_at.blank? ? "receive-help-offer" : "decline-help-offer"
  end

  def notify_pusher
    Pusher.trigger("helprequest-#{help_request.id}", define_pusher_name, nil)
  end
end
