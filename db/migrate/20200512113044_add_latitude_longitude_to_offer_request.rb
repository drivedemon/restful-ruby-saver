class AddLatitudeLongitudeToOfferRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :offer_requests, :latitude, :text, :null => true
    add_column :offer_requests, :longitude, :text, :null => true
  end
end
