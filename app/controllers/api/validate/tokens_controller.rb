class Api::Validate::TokensController < Api::ApplicationController

  include DecodeJwtToken

  def validate_token
    token = decode_token(token: params.dig("token")).first
    current_date = Time.now.to_i

    if current_date > token["exp"]
      jwt = nil
      code_status = :bad_request
    else
      user = User.find_by(auth_token: token["auth_token"])
      user.auth_token = user.generate_auth_token
      user.save
      jwt = user.as_json_with_jwt
      code_status = :ok
    end

    render json: jwt, status: code_status
  end
end
