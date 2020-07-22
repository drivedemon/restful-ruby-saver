class AddChatIdToNotifications < ActiveRecord::Migration[6.0]
  def change
    add_reference :notifications, :chat, null: true, foreign_key: true
  end
end
