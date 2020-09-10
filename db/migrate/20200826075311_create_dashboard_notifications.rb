class CreateDashboardNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :dashboard_notifications do |t|
      t.references :dashboard_user
      t.integer :notification_type
      t.jsonb :notification_data
      t.timestamp :read_at

      t.timestamps
    end
  end
end
