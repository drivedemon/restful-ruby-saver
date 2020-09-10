class DashboardNotificationRemoveJob < ApplicationJob
  queue_as :default

  def perform(notification_id = nil, dashboard_user_id = nil)
    return if notification_id.blank? || dashboard_user_id.blank?
    
    ActionCable.server.broadcast "dashboard_notification_remove:#{dashboard_user_id}", notification_id
  end
end
