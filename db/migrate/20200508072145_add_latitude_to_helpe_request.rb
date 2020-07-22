class AddLatitudeToHelpeRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :help_requests, :latitude, :text, :null => true, after: :price
    add_column :help_requests, :longitude, :text, :null => true, after: :latitude
  end
end
