class CreateColorStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :color_statuses do |t|
      t.text :name

      t.timestamps
    end
  end
end
