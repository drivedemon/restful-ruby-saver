class AddUserDeviceToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :user_device_id, :string
  end
end
