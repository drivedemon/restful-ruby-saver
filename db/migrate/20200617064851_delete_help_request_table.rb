class DeleteHelpRequestTable < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key :help_requests, :help_request_statuses
    
    drop_table :help_request_statuses do |t|
      t.string :name

      t.timestamps
    end
  end
end
