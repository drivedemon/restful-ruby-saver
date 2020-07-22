class AddRateIdToNotifications < ActiveRecord::Migration[6.0]
  def change
    add_reference :notifications, :rate, null: true, foreign_key: true
  end
end
