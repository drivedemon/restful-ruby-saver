require 'active_support/concern'

module FetchGoogleAddress
  extend ActiveSupport::Concern

  def get_google_address
    if address.nil?
      results = Geocoder.search([latitude, longitude])
      address_from_result = results.first.address
      address_from_result.nil? ? GoogleFetchAddressJob.perform_later(self.class.name, id) : update_columns(address: address_from_result)
    end
  end
end
