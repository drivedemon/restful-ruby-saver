class RenameColumnMesssageInChats < ActiveRecord::Migration[6.0]
  def change
    rename_column :chats, :messsage, :message
  end
end
