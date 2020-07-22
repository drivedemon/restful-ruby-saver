class ChangeColumnImageName < ActiveRecord::Migration[6.0]
  def change
    rename_column :image_help_requests, :image_name, :image_key
    rename_column :users, :image_name, :image_key
  end
end
