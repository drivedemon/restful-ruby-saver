class ChangeColumnNameInChat < ActiveRecord::Migration[6.0]
  def change
    rename_column :chats, :image_key, :image_type
  end
end
