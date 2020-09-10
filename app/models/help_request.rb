class HelpRequest < ApplicationRecord
  reverse_geocoded_by :latitude, :longitude

  HELPER_REQUEST_TOPIC = I18n.t("notification_mobile.someone_need_help")
  REQUEST_HEADER_CSV = %w{level date_and_time description amount name status}
  REQUEST_COLUMN_CSV = %w{color_to_level formatted_created_at description formatted_price requester_name status}
  REQUEST_LOCATION_HEADER_CSV = %w{level date_and_time location amount name status}
  REQUEST_LOCATION_COLUMN_CSV = %w{color_to_level formatted_created_at address_with_lat_long formatted_price requester_name status}
  SPENDING_HEADER_CSV = %w{payment_number name date_and_time amount fee description status}
  EARNING_HEADER_CSV = %w{payment_number name date_and_time amount description status}
  SPENDING_COLUMN_CSV = %w{payment_number requester_name payment_date_and_time formatted_price fee description status}
  EARNING_COLUMN_CSV = %w{payment_number offer_requester_name payment_date_and_time formatted_price offer_request_description status}
  REQUEST_INFORMATION_HEADER_CSV = %w{level request_description date_and_time amount fee distance status helper_name}.freeze
  REQUEST_INFORMATION_COLUMN_CSV = %w{color_to_level description formatted_created_at formatted_price fee distance_scope status offer_requester_name}.freeze
  HEADER_FILE_NAME = %w{help-requests spending-histories earning-histories help-requests-location}.freeze
  REQUEST_HISTORY_HEADER_TYPE = %w{help_request_history}.freeze
  SPENDING_HISTORY_HEADER_TYPE = %w{spending_history}.freeze
  EARNING_HISTORY_HEADER_TYPE = %w{earning_history}.freeze
  HEADER_TYPE = %w{request_information}.freeze
  CSV_FILE_NAME = "%s-#{Date.today}.csv".freeze
  ATTACHMENT_TYPE = "attachment".freeze
  REQUEST_RANGE_DISTANCE = 'distance'.freeze
  REQUEST_RANGE_URGENT = 'urgent'.freeze

  enum color_status: { green: 1, yellow: 2, red: 3 }, _prefix: true
  enum status: { pending: 1, confirmed: 2, completed: 3, rejected: 4, cancelled: 5 }


  acts_as_paranoid

  default_scope { order(created_at: :desc) }

  after_commit :push_notify_in_distance, on: [:create, :update, :destroy]
  after_commit :get_google_address, on: [:create]
  after_destroy :notify_pusher
  belongs_to :user
  has_one :chat_room
  has_one :payment
  has_many :help_request_views
  has_many :image_help_requests, dependent: :destroy
  has_many :notifications
  has_many :offer_requests
  has_many :rates

  include GenerateCsv
  include FilterFromHeaderBackOffice
  include NotificationFcmFormat
  include FetchGoogleAddress

  scope :without_complete_status, -> { where.not(status: [:completed, :cancelled]) }
  scope :without_current_user, -> (current_user) { where.not(user_id: current_user) }
  scope :without_pending_status, -> { where.not(status: :pending).with_deleted }
  scope :with_current_user, -> (current_user) { where(user_id: current_user) }
  scope :with_complete_status, -> { where(status: [:completed, :cancelled]) }
  scope :with_pending_status, -> { where(status: :pending) }
  scope :with_urgent_request_today, -> { where(color_status: :red).with_deleted }

  validates_inclusion_of :status, in: statuses.keys
  validates_inclusion_of :color_status, in: color_statuses.keys
  validates_presence_of :color_status, :status, :latitude, :longitude, :price, :description, :distance_scope
  validates_numericality_of :price

  def set_offer_with_detail(current_user)
    {
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
        created_at: TimeToHumanWord.calculator_time_to_human_word(created_at),
        created_at_format: created_at.strftime("%d %B %Y"),
        distance: distance_from_user(current_user),
        is_owner: check_is_owner,
        seen_view_count: help_request_views.count || 0,
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
    return if saved_change_to_is_paid.present?
    full_description = "#{notification_status} - #{description}"
    users_with_same_color_status_within_range.each do |user|
      Pusher.trigger("user-#{user.id}", define_pusher_name(define_method_name), as_help_request_format(user))

      if transaction_include_any_action?([:create])
        notifications.create(help_request_id: id, user_id: user.id)
        FcmNotification.push_notification(HELPER_REQUEST_TOPIC, full_description, nil, user, as_fcm_notification_format)
      end
    end
  end

  private

  def address_with_lat_long
    address_name = address.present? ? address : "Not found"
    "#{address_name} (#{latitude}, #{longitude})"
  end

  def offer_request_description
    offer_requests.first.description.presence || "-"
  end

  def offer_requester_name
    offer_request = offer_requests.first
    return "-" if offer_request.nil?
    user = offer_request.user
    "#{user.first_name} #{user.last_name}"
  end

  def payment_number
    payment.present? ? payment.order_id : "-"
  end

  def payment_date_and_time
    payment.present? ? payment.created_at.in_time_zone : "-"
  end

  def color_to_level
    case color_status.to_sym
    when :green
      :Normal
    when :yellow
      :Assistance
    when :red
      :Urgent
    end
  end

  def formatted_price
    "#{price.to_s} kr"
  end

  def formatted_price_with_revenue
    "#{price.to_s} kr"
  end

  def fee
    payment.present? ? "#{payment.amount} kr" : "-"
  end

  def formatted_created_at
    created_at.in_time_zone
  end

  def requester_name
    user.full_name
  end

  def distance_from_user(user)
    DistanceCalc.coordinate_distance_calculator(
      user.latitude,
      user.longitude,
      latitude,
      longitude
    )
  end

  def define_method_name
    if transaction_include_any_action?([:create])
      :create
    elsif transaction_include_any_action?([:update])
      :update
    elsif transaction_include_any_action?([:destroy])
      :destroy
    end
  end

  def define_pusher_name(pusher_type)
    case pusher_type
    when :create
      "create-help-request"
    when :update
      "update-help-request"
    when :destroy
      "cancel-help-request"
    end
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
