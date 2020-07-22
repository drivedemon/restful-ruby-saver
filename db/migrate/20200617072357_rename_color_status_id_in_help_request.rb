class RenameColorStatusIdInHelpRequest < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key :help_requests, :color_statuses

    drop_table :color_statuses do |t|
      t.string :name

      t.timestamps
    end

    rename_column :help_requests, :color_status_id, :color_status
  end
end
