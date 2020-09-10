class GoogleFetchAddressJob < ApplicationJob
  queue_as :default

  def perform(model_name = nil, model_id = nil)
    return if model_name.blank? || model_id.blank?

    model_to_fetch = model_name.constantize.with_deleted.find_by(id: model_id)
    return if model_to_fetch && model_to_fetch.address

    address_from_google = search_to_google(model_to_fetch.latitude, model_to_fetch.longitude)
    model_to_fetch.update_columns(address: address_from_google) if address_from_google
  end

  private

  def search_to_google(latitude, longitude)
    results = Geocoder.search([latitude, longitude])
    results.first.address
  end
end
