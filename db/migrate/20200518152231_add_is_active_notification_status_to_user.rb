class AddIsActiveNotificationStatusToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :notification_status, :boolean, default: true
  end
end
