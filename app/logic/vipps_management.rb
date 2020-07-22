# app/logic/vipps_management.rb
module VippsManagement
  class Internal
    def set_ssl(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http
    end

    def get_response(http, request)
      response = http.request(request)
      JSON.parse(response.body)
    end

    def set_header_auth(request, token_type, token)
      request["Authorization"] = "#{token_type} #{token}"
    end

    def set_header(request, token_type = nil, token = nil, order_id = nil)
      if token_type.blank? && token.blank?
        request["client_id"] = Rails.application.credentials[:vipps][:client_id]
        request["client_secret"] = Rails.application.credentials[:vipps][:client_secret]
      else
        set_header_auth(request, token_type, token)
        request["Content-Type"] = "application/json"
      end
      request["X-Request-Id"] = "#{order_id}XIDC1" if order_id.present?
      request["Ocp-Apim-Subscription-Key"] = Rails.application.credentials[:vipps][:ocp_sub_key]
      request
    end
  end

  module_function
  def create_order(token_type, token, amount)
    uri = URI.parse(Rails.application.credentials[:vipps][:init_payment_url])
    http = Internal.new.set_ssl(uri)
    request = Net::HTTP::Post.new(uri.request_uri)

    request.body = {
      "merchantInfo": {
        "merchantSerialNumber": Rails.application.credentials[:vipps][:merchant_serial_number],
        "callbackPrefix": Rails.application.credentials[:vipps][:callback_prefix],
        "fallBack": Rails.application.credentials[:vipps][:fallback],
        "isApp": true
      },
      "customerInfo": {
        "mobileNumber": Rails.application.credentials[:vipps][:saver_mobile_number]
      },
      "transaction": {
        "orderId": SecureRandom.hex(15),
        "amount": amount,
        "transactionText": I18n.t(:payment_create),
        "skipLandingPage": false
      }
    }.to_json
    Internal.new.set_header(request, token_type, token)

    Internal.new.get_response(http, request)
  end

  def capture_order(token_type, token, amount, order_id)
    capture_url = "#{Rails.application.credentials[:vipps][:init_payment_url]}/#{order_id}/capture"
    uri = URI.parse(capture_url)
    http = Internal.new.set_ssl(uri)
    request = Net::HTTP::Post.new(uri.request_uri)

    request.body = {
      "merchantInfo": {
        "merchantSerialNumber": Rails.application.credentials[:vipps][:merchant_serial_number],
      },
      "transaction": {
        "amount": amount,
        "transactionText": I18n.t(:payment_success)
      }
    }.to_json
    Internal.new.set_header(request, token_type, token, order_id)

    Internal.new.get_response(http, request)
  end

  def get_payment_token
    uri = URI.parse(Rails.application.credentials[:vipps][:get_token_url])
    http = Internal.new.set_ssl(uri)
    request = Net::HTTP::Post.new(uri.request_uri)
    Internal.new.set_header(request)

    Internal.new.get_response(http, request)
  end

  def login(encode_secret, code)
    uri = URI.parse(Rails.application.credentials[:vipps][:login_url])
    http = Internal.new.set_ssl(uri)
    request = Net::HTTP::Post.new(uri.request_uri)

    request.set_form_data(
      {
        "grant_type" => Rails.application.credentials[:vipps][:grant_type],
        "code" => code,
        "redirect_uri" => Rails.application.credentials[:vipps][:redirect_url]
      }
    )
    Internal.new.set_header_auth(request, "Basic", encode_secret)

    Internal.new.get_response(http, request)
  end

  def user_profile(token)
    uri = URI.parse(Rails.application.credentials[:vipps][:user_info_url])
    http = Internal.new.set_ssl(uri)
    request = Net::HTTP::Get.new(uri.request_uri)
    Internal.new.set_header_auth(request, "Bearer", token)

    Internal.new.get_response(http, request)
  end
end
