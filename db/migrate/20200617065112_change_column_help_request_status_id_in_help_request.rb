class ChangeColumnHelpRequestStatusIdInHelpRequest < ActiveRecord::Migration[6.0]
  def change
    rename_column :help_requests, :help_request_status_id, :status
  end
end
