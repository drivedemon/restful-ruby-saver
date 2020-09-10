class AddIndexToLatitudeAndLongitude < ActiveRecord::Migration[6.0]
  def change
    add_index :help_requests, :latitude
    add_index :help_requests, :longitude
    add_index :offer_requests, :latitude
    add_index :offer_requests, :longitude
  end
end
