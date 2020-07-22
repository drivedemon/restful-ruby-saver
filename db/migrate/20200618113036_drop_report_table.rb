class DropReportTable < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key :user_reports, :reports

    drop_table :reports do |t|
      t.string :name

      t.timestamps
    end

    rename_table :user_reports, :reports
    
    add_column :reports, :type_id, :integer

    remove_column :reports, :report_id
  end
end
