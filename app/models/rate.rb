class Rate < ApplicationRecord
  @@rate_topic = 'You are the best!'

  after_create :create_notify_history, :push_notify_to_user
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
    FcmNotification.push_notification(@@rate_topic, comment, nil, offer_request.user, as_fcm_notification_format) if offer_request.user.notification_status
  end
end
