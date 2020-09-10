require 'active_support/concern'

module FilterFromHeaderBackOffice
  extend ActiveSupport::Concern

  included do

    scope :filter_by_past_date, -> (start_date) { where(
      "#{name.underscore.to_s.pluralize}.created_at between ? and ?",
      start_date,
      Time.now.utc.end_of_day)
    }
    scope :filter_by_role_id, -> (role_id) { where(role_id: role_id) }
    scope :filter_by_start_date, -> (start_date) { where("#{name.underscore.to_s.pluralize}.created_at >= ?",  Time.parse(start_date).utc) }
    scope :filter_by_end_date, -> (end_date) { where("#{name.underscore.to_s.pluralize}.created_at <= ?", Time.parse(end_date).utc) }
    scope :filter_by_name, -> (query) { where("CONCAT_WS(' ', lower(first_name), lower(last_name)) LIKE ?", "%#{query.downcase}%") }
    scope :filter_by_level, -> (level) { where(color_status: level) }
    scope :filter_by_reason, -> (reason_id) { where(type_id: reason_id) }
    scope :filter_by_reported_from_user, -> (user_id) { where("help_requests.user_id = #{user_id}").references(:reported_from) }
    scope :filter_by_location, -> (coordinates, radius = nil) { near(coordinates.split(',').map(&:strip), radius || 10, units: :km) }
    scope :filter_by_amount, -> (order) { reorder(price: order) }
    scope :filter_by_amount_spending, -> (order) { reorder(total_spending: order) }
    scope :filter_by_amount_earning, -> (order) { reorder(total_earning: order) }
    scope :filter_by_status, -> (status_id) { where(status: status_id) }
    scope :order_by_name, -> (order) { reorder("first_name #{order}, last_name #{order}") }
    scope :order_by_level, -> (order) { reorder(color_status: order) }
    scope :order_by_customer_fullname, -> (order) { includes(:user).reorder("users.first_name #{order}, users.last_name #{order}") }
    scope :order_by_created_at, -> (order) { reorder(created_at: order) }
    scope :order_by_role, -> (order) { includes(:role).reorder("roles.name #{order}") }
    scope :payment_within_range, -> (start_date, end_date) { where("payments.created_at >= ? and payments.created_at <= ?", start_date, end_date).references(:payment)}
    scope :sort_by_top_amount, -> { reorder(price: :desc) }

    scope :spending_history, (lambda do |user_id|
      if user_id.present?
        where(is_paid: true, user_id: user_id)
      else
        where(is_paid: true)
      end
    end)

    scope :earning_history, (lambda do |user_id|
      if user_id.present?
        where("offer_requests.helpee_request_status_id != 1
          AND offer_requests.helper_request_status_id != 1
          AND payments.help_request_id IS NOT NULL
          AND offer_requests.user_id = ?", user_id
        ).references(:offer_requests, :payment)
      else
        where("offer_requests.helpee_request_status_id != 1
          AND offer_requests.helper_request_status_id != 1
          AND payments.help_request_id IS NOT NULL"
        ).references(:offer_requests, :payment)
      end
    end)

  end
end
