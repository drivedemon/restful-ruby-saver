class AddDeletedAtToChatRoom < ActiveRecord::Migration[6.0]
  def change
    add_column :chat_rooms, :deleted_at, :datetime
    add_index :chat_rooms, :deleted_at
  end
end
