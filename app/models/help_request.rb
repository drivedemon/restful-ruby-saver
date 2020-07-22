class HelpRequest < ApplicationRecord
  @@helper_request_topic = 'Someone needs help in your area!'

  enum color_status: { green: 1, yellow: 2, red: 3 }, _prefix: true
  enum status: { pending: 1, confirmed: 2, completed: 3, rejected: 4, cancelled: 5 }

  REQUEST_RANGE_DISTANCE = 'distance'
  REQUEST_RANGE_URGENT = 'urgent'

  acts_as_paranoid

  default_scope { order(created_at: :desc) }

  after_create :push_notify_in_distance
  after_destroy :notify_pusher
  belongs_to :user
  has_one :chat_room
  has_one :payment
  has_many :help_request_views
  has_many :image_help_requests, dependent: :destroy
  has_many :notifications
  has_many :offer_requests
  has_many :rates

  include NotificationFcmFormat

  scope :with_current_user, -> (current_user) { where(user_id: current_user) }
  scope :with_urgent_request_today, -> { where("created_at between ? and ?", Time.zone.now.beginning_of_day, Time.zone.now.end_of_day).where(color_status: :red).with_deleted }
  scope :with_pending_status, -> { where(status: :pending) }
  scope :without_complete_status, -> { where.not(status: :completed) }
  scope :without_current_user, -> (current_user) { where.not(user_id: current_user) }
  scope :without_pending_status, -> { where.not(status: :pending).with_deleted }

  validates_inclusion_of :status, in: statuses.keys
  validates_inclusion_of :color_status, in: color_statuses.keys
  validates_presence_of :color_status, :status, :latitude, :longitude, :price, :description, :distance_scope
  validates_numericality_of :price

  def set_offer_with_detail(current_user)
    {
      created_at: TimeToHumanWord.calculator_time_to_human_word(created_at),
      created_at_format: created_at.strftime("%d %B %Y"),
      distance: distance_from_user(current_user),
      my_offer: offer_requests.map{ |e|
        next unless e.user.auth_token == current_user.auth_token
        e.as_offer_request_format(current_user)
      }.compact,
      offer_request_count_all: offer_requests.count,
      offer_request_count_without_confirm: offer_requests.with_pending_status(OfferRequest::PENDING_STATUS).count,
      offer_request: offer_requests.present? ? offer_requests.map{ |e| e.as_offer_request_format(current_user) } : nil,
      offer_request_confirm: offer_requests.map{ |e|
        next unless [OfferRequest::CONFIRM_STATUS, OfferRequest::COMPLETE_STATUS].include? e.helpee_request_status_id
        e.as_offer_request_format(current_user)
      }.compact,
      seen_view_count: help_request_views.count,
      is_owner: user.auth_token == current_user.auth_token,
      user: user&.as_profile_json
    }
  end

  def as_help_request_format(current_user, display_offer_detail = false)
    check_is_owner = user.auth_token == current_user.auth_token
    request_feed = if display_offer_detail
      set_offer_with_detail(current_user)
    else
      {}
    end
    json = self.slice(:id, :description, :price, :color_status_id, :status_id, :distance_scope, :image_help_requests, :is_paid).merge(
      {
        is_owner: check_is_owner,
        user: user&.as_profile_json
      }
    )

    json.merge(request_feed)
  end

  def status_id
    self.class.statuses[status]
  end

  def color_status_id
    self.class.color_statuses[color_status]
  end

  def check_user_in_distance(current_user)
    distance_scope >= distance_from_user(current_user) &&
    (
      (color_status_green? && distance_from_user(current_user) <= current_user.green_distance_scope) ||
      (color_status_yellow? && distance_from_user(current_user) <= current_user.yellow_distance_scope) ||
      (color_status_red? && distance_from_user(current_user) <= current_user.red_distance_scope)
    )
  end

  def push_notify_in_distance
    full_description = "#{notification_status} - #{description}"
    users_with_same_color_status_within_range.each do |user|

      notifications.create(help_request_id: id, user_id: user.id)
      Pusher.trigger("helprequest-#{id}", define_pusher_name(:create), as_help_request_format(user))
      FcmNotification.push_notification(@@helper_request_topic, full_description, nil, user, as_fcm_notification_format)

    end
  end

  private
  def distance_from_user(user)
    DistanceCalc.coordinate_distance_calculator(
      user.latitude,
      user.longitude,
      latitude,
      longitude
    )
  end

  def define_pusher_name(pusher_type)
    pusher_type == :create ? "create-help-request" : "cancel-help-request"
  end

  def notification_status
    if color_status_green?
      Notification::GREEN_LEVEL_MESSAGE
    elsif color_status_yellow?
      Notification::YELLOW_LEVEL_MESSAGE
    elsif color_status_red?
      Notification::RED_LEVEL_MESSAGE
    end
  end

  def notify_pusher
    Pusher.trigger("helprequest-#{id}", define_pusher_name(:destroy), nil)
  end

  def users_with_same_color_status_within_range
    users = User.where(notification_status: true).where.not(id: user_id)
    if color_status_green?
      users = users.where(notification_status_green: true)
    elsif color_status_yellow?
      users = users.where(notification_status_yellow: true)
    elsif color_status_red?
      users = users.where(notification_status_red: true)
    end
    users.to_a.select do |user|
      check_user_in_distance(user)
    end
  end
end
