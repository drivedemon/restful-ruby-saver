class CreateHelpRequestStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :help_request_statuses do |t|
      t.string :name

      t.timestamps
    end
  end
end
