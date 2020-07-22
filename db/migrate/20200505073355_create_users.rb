class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.text :name
      t.text :lat
      t.text :long

      t.timestamps
    end
  end
end
