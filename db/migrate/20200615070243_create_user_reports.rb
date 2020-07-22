class CreateUserReports < ActiveRecord::Migration[6.0]
  def change
    create_table :user_reports do |t|
      t.references :help_request, null: false, foreign_key: true
      t.references :offer_request, null: false, foreign_key: true
      t.references :report, null: false, foreign_key: true
      t.text :comment, null: true

      t.timestamps
    end
  end
end
