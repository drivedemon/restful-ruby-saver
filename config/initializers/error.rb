Rails.configuration.to_prepare do
  class BadError < StandardError
  end

  class AuthenticationError < StandardError
  end
end
