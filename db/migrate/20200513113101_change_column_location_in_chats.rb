class ChangeColumnLocationInChats < ActiveRecord::Migration[6.0]
  def change
    remove_column :chats, :location
    add_column :chats, :latitude, :text, :null => true
    add_column :chats, :longitude, :text, :null => true
  end
end
