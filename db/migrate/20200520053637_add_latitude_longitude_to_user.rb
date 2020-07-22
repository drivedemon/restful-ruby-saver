class AddLatitudeLongitudeToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :latitude, :text
    add_column :users, :longitude, :text
  end
end
