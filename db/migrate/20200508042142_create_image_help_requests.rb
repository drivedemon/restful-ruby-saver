class CreateImageHelpRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :image_help_requests do |t|
      t.references :help_request, null: false, foreign_key: true
      t.text :image_name
      t.text :image_path

      t.timestamps
    end
  end
end
