require 'geocoder'

Geocoder.configure(
  api_key: Rails.application.credentials[:google][:api_key],
  use_https: true
)