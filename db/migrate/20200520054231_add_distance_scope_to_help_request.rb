class AddDistanceScopeToHelpRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :help_requests, :distance_scope, :float
  end
end
