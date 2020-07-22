class AddDistanceRangeToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :green_distance_scope, :float, default: 5.00
    add_column :users, :yellow_distance_scope, :float, default: 15.00
    add_column :users, :red_distance_scope, :float, default: 30.00
  end
end
