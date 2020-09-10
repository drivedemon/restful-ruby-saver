require 'active_support/concern'

module NotificationFcmFormat
  extend ActiveSupport::Concern

  def as_fcm_notification_format
    {
      key => value,
      "help_request" => additional_help_request_id
    }
  end

  private

  def key
    self.class.name.underscore
  end

  def value
    id
  end

  def additional_help_request_id
    case key.to_sym
    when :help_request
      id
    when :offer_request
      help_request_id
    when :chat_room
      help_request_id
    when :chat
      chat_room.help_request_id
    end
  end
end
