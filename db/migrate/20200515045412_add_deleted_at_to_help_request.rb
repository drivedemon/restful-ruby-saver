class AddDeletedAtToHelpRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :help_requests, :deleted_at, :datetime
    add_index :help_requests, :deleted_at
  end
end
