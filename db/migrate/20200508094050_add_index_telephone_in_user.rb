class AddIndexTelephoneInUser < ActiveRecord::Migration[6.0]
  def change
    add_index :users, :telephone, unique: true
  end
end
