class Report < ApplicationRecord
  REPORT_LIST_HEADER_CSV = %w{name reason reason_type date_and_time reported_by status}.freeze
  REPORT_LIST_COLUMN_CSV = %w{full_name_reported_to report_type_to_wording type_id formatted_created_at full_name_reported_from own_status}.freeze
  REPORT_INFORMATION_HEADER_CSV = %w{reported_by date_and_time reason reason_type request_description}.freeze
  REPORT_INFORMATION_COLUMN_CSV = %w{full_name_reported_from formatted_created_at report_type_to_wording type_id request_description}.freeze
  HEADER_TYPE = %w{report_history}.freeze
  HEADER_FILE_NAME = %w{reports}.freeze
  CSV_FILE_NAME = "%s-#{Date.today}.csv".freeze
  ATTACHMENT_TYPE = "attachment".freeze
  SPAM_WORDING = I18n.t("notification_mobile.report_type.spam")
  PRETENING_WORDING = I18n.t("notification_mobile.report_type.pretending")
  HATEFUL_WORDING = I18n.t("notification_mobile.report_type.hateful")

  enum type_id: {
    spam: 1,
    pretending: 2,
    hateful: 3,
    other: 4
  }

  include GenerateCsv
  include FilterFromHeaderBackOffice

  belongs_to :help_request
  belongs_to :offer_request
  belongs_to :reported_from, -> { with_deleted }, class_name: 'HelpRequest', foreign_key: "help_request_id", optional: true
  belongs_to :reported_to, -> { with_deleted }, class_name: 'OfferRequest', foreign_key: "offer_request_id", optional: true

  delegate :user, to: :reported_from, prefix: true
  delegate :user, to: :reported_to, prefix: true

  def full_name_reported_to
    reported_to_user.full_name
  end

  def report_type_to_wording
    case type_id.to_sym
    when :spam
      SPAM_WORDING
    when :pretending
      PRETENING_WORDING
    when :hateful
      HATEFUL_WORDING
    when :other
      comment
    end
  end

  def formatted_created_at
    created_at.in_time_zone
  end

  def own_status
    reported_to_user.status
  end

  def full_name_reported_from
    reported_from_user.full_name
  end
  def request_description
    reported_from.description
  end
end
