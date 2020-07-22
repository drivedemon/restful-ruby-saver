class CreateHelpRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :help_requests do |t|
      t.text :description
      t.float :price
      t.integer :status
      t.references :color_status, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
