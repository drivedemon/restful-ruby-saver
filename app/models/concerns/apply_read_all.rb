require 'active_support/concern'

module ApplyReadAll
  extend ActiveSupport::Concern

  class_methods do
    def define_pusher_name
      case name.downcase.to_sym
      when :notification
        "remove-notifications"
      when :chat
        "remove-conversation"
      end
    end

    def read_all!(current_user)
      count = where(is_read: false).update_all(is_read: true)
      Pusher.trigger("user-#{current_user.id}", define_pusher_name, count) if count > 0
    end
  end
end
