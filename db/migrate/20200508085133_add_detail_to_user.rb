class AddDetailToUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :name, :text
    add_column :users, :first_name, :string, :null => false, :after => :id
    add_column :users, :last_name, :string, :null => false, :after => :first_name
    add_column :users, :telephone, :string, :null => false, :after => :last_name
    add_column :users, :username, :string, :null => false, :after => :telephone
    add_column :users, :image_name, :text, :null => true, :after => :username
    add_column :users, :image_path, :text, :null => true, :after => :image_name
  end
end
