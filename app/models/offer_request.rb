class OfferRequest < ApplicationRecord
  OFFER_REQUEST_TOPIC = I18n.t("notification_mobile.someone_offer")
  ACCEPT_REQUEST_TOPIC = I18n.t("notification_mobile.accepted_your_offer")
  ACCEPT_OFFER_TOPIC = I18n.t("notification_mobile.confirmed_your_request")
  COMPLETE_REQUEST_TOPIC = I18n.t("notification_mobile.marked_your_offer_completed")
  COMPLETE_OFFER_TOPIC = I18n.t("notification_mobile.marked_your_request_completed")
  REJECT_OFFER_TOPIC = I18n.t("notification_mobile.requester_chosen_another")
  REJECT_OFFER_DESCRIPTION = I18n.t("notification_mobile.request_no_longer_open_to_help")
  CANCEL_ACCEPT_HELPEE_TOPIC = I18n.t("notification_mobile.rejected_accept_confirmed")
  CANCEL_ACCEPT_OFFER_TOPIC = I18n.t("notification_mobile.cancelled_accept_help")
  OFFER_HEADER_CSV = %w{level date_and_time description amount name status}
  OFFER_COLUMN_CSV = %w{color_to_level formatted_created_at help_request_description formatted_price requester_name help_request_status}
  HEADER_TYPE = %w{offer_history}.freeze

  PENDING_STATUS = 1
  CONFIRM_STATUS = 2
  COMPLETE_STATUS = 3
  REJECT_STATUS = 4

  acts_as_paranoid

  default_scope { order(created_at: :desc) }

  after_commit :create_notify_history, on: :create
  after_commit :notify_pusher, on: [:create, :destroy]
  after_commit :push_notify_to_user, on: [:create, :update]
  after_commit :get_google_address, on: [:create]
  after_commit :create_reject_message, :push_notify_after_reject, on: :destroy
  belongs_to :helpee_request_status
  belongs_to :helper_request_status
  belongs_to :help_request
  belongs_to :owned_help_request, -> { with_deleted }, class_name: 'HelpRequest', foreign_key: "help_request_id", optional: true
  belongs_to :user
  has_one :chat_room
  has_many :notifications
  has_many :rates

  delegate :user, to: :owned_help_request, prefix: true

  include FilterFromHeaderBackOffice
  include NotificationFcmFormat
  include FetchGoogleAddress

  scope :sort_by_top_user, -> { joins(:user).group(:user).order('count_all DESC') }
  scope :with_complete_status, -> { where(helper_request_status_id: [COMPLETE_STATUS, REJECT_STATUS]) }
  scope :with_current_user, -> { where(user_id: current_user) }
  scope :with_pending_status, -> (status) { where(helpee_request_status_id: status) }
  scope :without_pending_status, -> { where.not(helper_request_status_id: PENDING_STATUS) }
  scope :without_confirm_status, -> (offer_request) { where(help_request_id: offer_request.help_request_id).where.not(user_id: offer_request.user_id).with_deleted }
  scope :without_complete_status, -> { where.not(helper_request_status_id: [COMPLETE_STATUS, REJECT_STATUS]) }

  validates_presence_of :latitude, :longitude
  validates :help_request_id, presence: true, numericality: true

  def as_offer_request_format(current_user, display_deleted_offer = false)
    self.slice(:id, :description, :helpee_request_status_id, :helper_request_status_id, :rates).merge(
      {
        created_at: TimeToHumanWord.calculator_time_to_human_word(created_at),
        created_at_format: created_at.strftime("%d %B %Y"),
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

  def self.create_notify_history(
    action_type:,
    receive_id:,
    chat_model: nil,
    offer_request_model: nil
  )
    model_data = action_type == :chat ? chat_model : offer_request_model
    Notification.create(self.set_param_notification(action_type, model_data).merge({ user_id: receive_id }))
  end

  def self.create_notify_history_after_reject
    notifications.create(user_id: help_request.user_id)
  end

  def create_reject_message
    Chat.create(type: RejectChat::MESSAGE, chat_room_id: chat_room.id, user_id: help_request.user_id) if chat_room.present?
  end

  def push_notify_to_user
    return unless get_owner_user.notification_status
    force_topic = define_topic_notification(saved_change_to_helpee_request_status_id, saved_change_to_helper_request_status_id)
    FcmNotification.push_notification(force_topic % get_owner_user.username, description, nil, get_owner_user, as_fcm_notification_format)
  end

  def push_notify_after_reject
    FcmNotification.push_notification(REJECT_OFFER_TOPIC, REJECT_OFFER_DESCRIPTION, nil, user, as_fcm_notification_format) if user.notification_status && chat_room.present?
  end

  def self.notify_pusher(
    help_request_id:,
    event_name:
  )
    Pusher.trigger("helprequest-#{help_request_id}", event_name, nil)
  end

  def self.set_param_notification(action_type, model_data)
    case action_type
    when :chat
      {
        chat_room_id: model_data.chat_room.id,
        chat_id: model_data.id
      }
    else
      {
        offer_request_id: model_data.id,
        is_offer_cancelled: true
      }
    end
  end

  private

  def define_topic_notification(changed_helpee_status_id, changed_helper_status_id)
    return OFFER_REQUEST_TOPIC if changed_helpee_status_id.blank? && changed_helper_status_id.blank?
    # helpee section
    if changed_helpee_status_id.present?
      return case changed_helpee_status_id[1]
      when PENDING_STATUS # cancel self accept
        CANCEL_ACCEPT_OFFER_TOPIC
      when CONFIRM_STATUS
        ACCEPT_REQUEST_TOPIC
      when COMPLETE_STATUS
        COMPLETE_REQUEST_TOPIC
      end
    end
    # helper section
    if changed_helper_status_id.present?
      return case changed_helper_status_id[1]
      when REJECT_STATUS # cancel accept from helper
        CANCEL_ACCEPT_HELPEE_TOPIC
      when CONFIRM_STATUS
        ACCEPT_OFFER_TOPIC
      when COMPLETE_STATUS
        COMPLETE_OFFER_TOPIC
      end
    end
  end

  def get_owner_user
    saved_change_to_helpee_request_status_id.present? ? owned_help_request_user : user
  end

  def define_pusher_name
    deleted_at.blank? ? "receive-help-offer" : "decline-help-offer"
  end

  def notify_pusher
    Pusher.trigger("helprequest-#{help_request.id}", define_pusher_name, nil)
  end

  def color_to_level
    case owned_help_request.color_status.to_sym
    when :green
      :Normal
    when :yellow
      :Assistance
    when :red
      :Urgent
    end
  end

  def formatted_created_at
    created_at.in_time_zone
  end

  def formatted_price
    "#{owned_help_request.price.to_s} kr"
  end

  def requester_name
    user.full_name
  end

  def help_request_description
    owned_help_request.description
  end

  def help_request_status
    owned_help_request.status
  end
end
