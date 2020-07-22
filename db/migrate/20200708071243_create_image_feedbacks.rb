class CreateImageFeedbacks < ActiveRecord::Migration[6.0]
  def change
    create_table :image_feedbacks do |t|
      t.references :feedback, null: false, foreign_key: true
      t.string :image_key
      t.string :image_path

      t.timestamps
    end
  end
end
