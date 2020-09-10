class DashboardNotificationRemoveChannel < ApplicationCable::Channel
  def subscribed
    stream_from "dashboard_notification_remove:#{current_dashboard_user.id}"
  end

  def unsubscribed
    stop_all_streams
  end
end
