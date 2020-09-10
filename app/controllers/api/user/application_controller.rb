class Api::User::ApplicationController < Api::ApplicationController
  before_action :set_current_user_from_header
  before_action :check_banned_user

  include DecodeJwtToken

  def set_current_user_from_header
    auth_header = request.headers["auth-token"]
    jwt = auth_header.split(" ").last rescue nil
    payload = decode_token(token: jwt).first
    @current_user = User.find_by(auth_token: payload["auth_token"])
  rescue
    # return @current_user nil
  end

  def check_banned_user
    return if @current_user.nil?
    raise AuthenticationError.new("User banned") if @current_user.status.to_sym == :banned
  end

  def current_user(auth = true)
    raise AuthenticationError.new("Not logged in or invalid auth token") if auth && @current_user.blank?
    @current_user
  end
end
