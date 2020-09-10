class AddSettingsToDashboardUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :dashboard_users, :receive_notification, :boolean, default: true
    add_column :dashboard_users, :dashboard_language, :string, default: "nn"
  end
end
