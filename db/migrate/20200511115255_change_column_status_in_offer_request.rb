class ChangeColumnStatusInOfferRequest < ActiveRecord::Migration[6.0]
  def change
    change_column :offer_requests, :helpee_status, :integer, :default => 1
    change_column :offer_requests, :helper_status, :integer, :default => 1
  end
end
