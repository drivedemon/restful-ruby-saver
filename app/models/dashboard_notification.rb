class DashboardNotification < ApplicationRecord
  enum notification_type: { user_sign_up: 1, user_reported: 2, new_help_request: 3 }

  default_scope { order(created_at: :desc) }

  belongs_to :dashboard_user

  validate :validate_notification_data_against_json_schema
  validates_inclusion_of :notification_type, in: notification_types.keys
  validates_presence_of :notification_type, :notification_data

  scope :unread, -> { where(read_at: nil) }

  private
  def validate_notification_data_against_json_schema
    notification_data_errors = JSON::Validator.fully_validate(
      notification_data_schema, 
      notification_data, 
      validate_schema: true
    )
    notification_data_errors.each do |error|
      errors.add(:notification_data, error)
    end
  end

  def notification_data_schema
    {
      "type": "object",
      "properties": {
        "sign_up_user_id": {
          "type": "integer"
        },
        "report_id": {
          "type": "integer"
        },
        "new_request_id": {
          "type": "integer"
        }
      },
      "additionalProperties": false
    }
  end
end
