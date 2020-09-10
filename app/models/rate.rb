class Rate < ApplicationRecord
  RATE_TOPIC = I18n.t("notification_mobile.you_are_the_best")

  after_commit :create_notify_history, :push_notify_to_user, on: :create
  belongs_to :user
  belongs_to :offer_request
  has_many :notifications

  include NotificationFcmFormat

  def as_rate_format(current_user)
    self.slice(:id, :score, :comment).merge(
      {
        offer_request: offer_request.as_self_user_format(current_user)
      }
    )
  end

  def as_rate_notification_format(current_user)
    self.slice(:id, :score, :comment).merge(
      {
        rate_owner: offer_request.help_request&.as_help_request_format(current_user)
      }
    )
  end

  def create_notify_history
    notifications.create(user_id: offer_request.user.id)
  end

  def push_notify_to_user
    FcmNotification.push_notification(RATE_TOPIC, comment, nil, offer_request.user, as_fcm_notification_format) if offer_request.user.notification_status
  end
end
