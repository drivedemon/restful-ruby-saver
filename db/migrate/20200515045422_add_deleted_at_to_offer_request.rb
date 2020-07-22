class AddDeletedAtToOfferRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :offer_requests, :deleted_at, :datetime
    add_index :offer_requests, :deleted_at
  end
end
