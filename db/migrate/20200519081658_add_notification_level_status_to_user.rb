class AddNotificationLevelStatusToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :notification_status_green, :boolean, default: true
    add_column :users, :notification_status_yellow, :boolean, default: true
    add_column :users, :notification_status_red, :boolean, default: true
  end
end
