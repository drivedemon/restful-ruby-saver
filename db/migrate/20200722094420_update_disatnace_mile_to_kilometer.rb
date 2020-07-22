class UpdateDisatnaceMileToKilometer < ActiveRecord::Migration[6.0]
  def change
    User.update_all(
      :green_distance_scope => 50,
      :yellow_distance_scope => 50,
      :red_distance_scope => 50
    )
  end
end
