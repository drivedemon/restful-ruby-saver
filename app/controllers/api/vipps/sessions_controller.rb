class Api::Vipps::SessionsController < Api::User::ApplicationController
  skip_before_action :set_current_user_from_header, only: [:index]
  skip_before_action :check_banned_user, only: [:index]
  before_action :vipps_login, only: [:index]
  before_action :vipps_get_token, only: [:payment, :capture]
  before_action :set_locale_language, only: [:payment, :capture]
  before_action :set_help_request, only: [:capture]

  def index
    vipps_user = VippsManagement.user_profile(@vipps_login['access_token'])
    render json: vipps_user, status: vipps_user['status_code']
  end

  def payment
    vipps_order = VippsManagement.create_order(
      @vipps_token['token_type'],
      @vipps_token['access_token'],
      params[:amount] # 100 = 1kr
    )
    return render json: vipps_order, status: :bad_request if check_response?(vipps_order)
    render json: vipps_order
  end

  def capture
    vipps_capture = VippsManagement.capture_order(
      @vipps_token['token_type'],
      @vipps_token['access_token'],
      calculate_capture_amount * 100, # 100 = 1kr
      params[:order_id]
    )
    return render json: vipps_capture, status: :bad_request if check_response?(vipps_capture)

    @help_request.update(is_paid: true)
    Payment.create(
      order_id: params[:order_id],
      amount: calculate_capture_amount,
      help_request_id: @help_request.id,
      user_id: current_user.id
    )
    render json: @help_request
  end

  private
  def calculate_capture_amount
    (@help_request.price * 20 / 100).to_i
  end

  def set_help_request
    @help_request = HelpRequest.find(params[:help_request_id])
  end

  def set_locale_language
    I18n.locale = params[:locale].present? ? params[:locale].to_sym : :nn
  end

  def vipps_login
    @vipps_login = VippsManagement.login(params[:encodesecret], params[:code])
    return render json: @vipps_login, status: @vipps_login['status_code'] if check_access_token?(:login)
  end

  def vipps_get_token
    @vipps_token = VippsManagement.get_payment_token
    return render json: @vipps_token, status: @vipps_token['status_code'] if check_access_token?(:get_token)
  end

  def check_access_token?(menu)
    case menu
    when :login
      @vipps_login['access_token'].blank?
    when :get_token
      @vipps_token['access_token'].blank?
    end
  end

  def check_response?(response)
    response.kind_of?(Array)
  end
end
