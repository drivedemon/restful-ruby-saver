class AddStatusToHelpRequest < ActiveRecord::Migration[6.0]
  def change
    remove_column :help_requests, :status, :integer
    add_column :help_requests, :status, :integer, :null => true, :default => 1
  end
end
