class ChangeStatusInHelpRequest < ActiveRecord::Migration[6.0]
  def change
    remove_column :help_requests, :status
    add_reference :help_requests, :help_request_status, :null => true, :default => 1, foreign_key: true
  end
end
