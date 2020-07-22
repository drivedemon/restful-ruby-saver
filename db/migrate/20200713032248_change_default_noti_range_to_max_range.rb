class ChangeDefaultNotiRangeToMaxRange < ActiveRecord::Migration[6.0]
  def change
    change_column_default(:users, :green_distance_scope, 30)
    change_column_default(:users, :yellow_distance_scope, 30)
    change_column_default(:users, :red_distance_scope, 30)

    User.update_all(
      :green_distance_scope => 30,
      :yellow_distance_scope => 30,
      :red_distance_scope => 30
    )
  end
end
