class AddOfferRejectColumnIntoNotifications < ActiveRecord::Migration[6.0]
  def change
    add_column :notifications, :is_offer_rejected, :boolean, default: false
  end
end
