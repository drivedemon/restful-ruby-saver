class AddSelfCancelledOffer < ActiveRecord::Migration[6.0]
  def change
    add_column :notifications, :is_offer_cancelled, :boolean, default: false
  end
end
