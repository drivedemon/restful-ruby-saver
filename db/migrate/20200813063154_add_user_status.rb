class AddUserStatus < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :status, :integer, default: 1
  end
end
