require 'active_support/concern'

module DashboardNotificationTrigger
  extend ActiveSupport::Concern

  def store_and_trigger_notification_job(notification_type, notification_data)
    DashboardNotificationHandlerJob.perform_later(
      notification_type,
      notification_data
    )
  end

  def updated_read_at_notification(from_notification_params:)
    return unless from_notification_params[:from_notification].present?

    dashboard_notification = current_dashboard_user.dashboard_notifications.find_by(id: from_notification_params[:from_notification])

   if dashboard_notification && dashboard_notification.read_at.nil?
      dashboard_notification.update(read_at: Time.now)
      remove_and_trigger_notification_job(from_notification_params[:from_notification], current_dashboard_user.id)
   end
  end

  private

  def remove_and_trigger_notification_job(notification_type, notification_data)
    DashboardNotificationRemoveJob.perform_later(
      notification_type,
      notification_data
    )
  end
end
