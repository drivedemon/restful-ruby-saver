class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.boolean :is_read, default: false
      t.references :help_request, null: true, foreign_key: true
      t.references :offer_request, null: true, foreign_key: true
      t.references :chat_room, null: true, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
