class Api::User::ApplicationController < Api::ApplicationController
  before_action :set_current_user_from_header

  def set_current_user_from_header
    auth_header = request.headers["auth-token"]
    jwt = auth_header.split(" ").last rescue nil
    payload = JWT.decode(jwt, Rails.application.credentials.secret_key_base, true, { algorithm: "HS256" }).first
    @current_user = User.find_by(auth_token: payload["auth_token"])
  rescue
    # return @current_user nil
  end

  def current_user(auth = true)
    raise AuthenticationError.new("Not logged in or invalid auth token") if auth && @current_user.blank?
    @current_user
  end
  
  def update_user_location
    @current_user.update_location(params[:current_latitude], params[:current_longitude])
  end
end
