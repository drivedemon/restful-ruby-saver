class ChangeHelpStatusInOfferRequest < ActiveRecord::Migration[6.0]
  def change
    remove_column :offer_requests, :helpee_status
    add_reference :offer_requests, :helpee_request_status, :null => true, :default => 1, foreign_key: true
    remove_column :offer_requests, :helper_status
    add_reference :offer_requests, :helper_request_status, :null => true, :default => 1, foreign_key: true

  end
end
