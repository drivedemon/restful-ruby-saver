class AddUsernameToDashboadUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :dashboard_users, :username, :string
    add_index :dashboard_users, :username, unique: true
  end
end
