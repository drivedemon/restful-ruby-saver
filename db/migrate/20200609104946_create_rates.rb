class CreateRates < ActiveRecord::Migration[6.0]
  def change
    create_table :rates do |t|
      t.references :user, null: false, foreign_key: true
      t.float :score
      t.text :comment
      t.references :offer_request, null: false, foreign_key: true

      t.timestamps
    end
  end
end
