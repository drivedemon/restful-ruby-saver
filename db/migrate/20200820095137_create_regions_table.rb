class CreateRegionsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :regions do |t|
      t.string :country_iso, default: "no"
      t.string :timezone, default: "Europe/Oslo"
      t.timestamps
    end
    
    add_reference :dashboard_users, :region, index: true
  end
end
