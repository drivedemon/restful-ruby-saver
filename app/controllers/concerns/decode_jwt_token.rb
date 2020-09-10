require 'active_support/concern'

module DecodeJwtToken
  extend ActiveSupport::Concern

  def decode_token(token:)
    JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: "HS256" })
  end
end
