class AddContentTypeIntoAllUploadTable < ActiveRecord::Migration[6.0]
  def change
    add_column :chats, :image_key, :string, null: true

    rename_column :chats, :image, :image_path
    rename_column :image_help_requests, :image_key, :image_type
    rename_column :image_feedbacks, :image_key, :image_type
    rename_column :users, :image_key, :image_type
  end
end
