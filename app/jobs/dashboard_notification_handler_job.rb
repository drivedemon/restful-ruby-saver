class DashboardNotificationHandlerJob < ApplicationJob
  queue_as :default

  def perform(notification_type = nil, notification_data = {})
    return if notification_type.blank? || notification_data.blank? || !DashboardNotification.notification_types.keys.include?(notification_type.to_s)
    noti_on_dashboard_users = DashboardUser.with_notification_on
    noti_on_dashboard_users.each do |dashboard_user|
      dashboard_notification = DashboardNotification.new(
        dashboard_user: dashboard_user,
        notification_type: notification_type,
        notification_data: notification_data
      )
      if dashboard_notification.save
        html_to_render = convert_data_to_html(notification_type, notification_data, dashboard_user, dashboard_notification)
        ActionCable.server.broadcast "dashboard_notifications:#{dashboard_user.id}", {html: html_to_render}
      end
    end
  end

  private

  def convert_data_to_html(notification_type, notification_data, dashboard_user, dashboard_notification)
    timezone = if dashboard_user.region.present?
      dashboard_user.region.timezone
    else
      "Europe/Oslo"
    end
    html_rendered = I18n.with_locale(dashboard_user.dashboard_language || "nn") do
      ApplicationController.render partial: "dashboard_notifications/#{notification_type.to_s}",
        locals: {
          notification_data: notification_data,
          dashboard_notification_id: dashboard_notification.id,
          dashboard_notification_at: dashboard_notification.created_at.in_time_zone(timezone).strftime("%b %d, %Y %l:%M%P")
        },
        formats: [:html]
    end

    html_rendered
  end
end
