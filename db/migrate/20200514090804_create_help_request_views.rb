class CreateHelpRequestViews < ActiveRecord::Migration[6.0]
  def change
    create_table :help_request_views do |t|
      t.references :help_request, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
