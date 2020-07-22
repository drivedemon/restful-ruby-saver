class AddSoftDeleteIntoImageTable < ActiveRecord::Migration[6.0]
  def change
    add_column :image_help_requests, :deleted_at, :datetime
    add_index :image_help_requests, :deleted_at

    add_column :image_feedbacks, :deleted_at, :datetime
    add_index :image_feedbacks, :deleted_at
  end
end
