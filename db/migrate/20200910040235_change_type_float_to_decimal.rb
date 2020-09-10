class ChangeTypeFloatToDecimal < ActiveRecord::Migration[6.0]
  def up
    change_column :help_requests, :latitude, :decimal, :precision => 9, :scale => 6
    change_column :help_requests, :longitude, :decimal, :precision => 9, :scale => 6
    change_column :offer_requests, :latitude, :decimal, :precision => 9, :scale => 6
    change_column :offer_requests, :longitude, :decimal, :precision => 9, :scale => 6
    change_column :chats, :latitude, :decimal, :precision => 9, :scale => 6
    change_column :chats, :longitude, :decimal, :precision => 9, :scale => 6
    change_column :users, :latitude, :decimal, :precision => 9, :scale => 6
    change_column :users, :longitude, :decimal, :precision => 9, :scale => 6
  end

  def down
    change_column :help_requests, :latitude, :float
    change_column :help_requests, :longitude, :float
    change_column :offer_requests, :latitude, :float
    change_column :offer_requests, :longitude, :float
    change_column :chats, :latitude, :float
    change_column :chats, :longitude, :float
    change_column :users, :latitude, :float
    change_column :users, :longitude, :float
  end
end
