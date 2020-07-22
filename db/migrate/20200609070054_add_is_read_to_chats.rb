class AddIsReadToChats < ActiveRecord::Migration[6.0]
  def change
    add_column :chats, :is_read, :boolean, default: false
  end
end
