class AddAddressToOfferRequestsAndHelpRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :help_requests, :address, :string
    add_column :offer_requests, :address, :string
  end
end
