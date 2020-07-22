require 'active_support/concern'

module NotificationFcmFormat
  extend ActiveSupport::Concern

  def as_fcm_notification_format
    {
      key => value
    }
  end

  private

  def key
    self.class.name.underscore
  end

  def value
    case key.to_sym
    when :offerrequest
      chat_room.id
    else
      id
    end
  end
end
