class DashboardNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "dashboard_notifications:#{current_dashboard_user.id}"
  end

  def unsubscribed
    stop_all_streams
  end
end
