class Api::User::SessionsController < Api::User::ApplicationController
  skip_before_action :set_current_user_from_header, only: [:sign_up, :sign_in]
  skip_before_action :check_banned_user, only: [:sign_up, :sign_in]

  include MergeImageParam
  include DashboardNotificationTrigger

  def sign_up
    # merge_image_param
    user = User.new(merge_first_row(user_params, params[:images]).merge({ password: params[:telephone] }))
    if user.save
      store_and_trigger_notification_job(:user_sign_up, {sign_up_user_id: user.id})
      render json: user.as_json_with_jwt, status: :created
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  def sign_in
    user = User.find_by(telephone: params[:telephone])
    raise BadError.new("Invalid telephone number") if user.blank?
    if user.valid_password?(params[:telephone])
      user.auth_token = user.generate_auth_token
      user.user_device_id = params[:user_device_id]
      user.save
      render json: user.as_json_with_jwt
    else
      raise AuthenticationError.new("Invalid telephone number or incorrect number")
    end
  end

  def sign_out
    current_user.generate_auth_token
    current_user.save
    render json: { success: true }
  end

  def remove
    user_parameter = params[:id].present? ? params[:id] : params[:email]
    user = if params[:id].present?
      User.find(user_parameter)
    else
      User.find_by(email: user_parameter)
    end
    random_text = SecureRandom.hex(5)

    user.reset_password(random_text, random_text)
    user.update(
      auth_token: nil,
      email: "anonymous_#{random_text}@saver.com",
      first_name: "anonymous",
      last_name: "anonymous",
      telephone: "#{rand(1000000000)}",
      username: "anonymous_#{random_text}",
      user_device_id: nil,
      status: :inactive,
    )
    user.destroy
  end

  def all
    render json: User.all
  end

  def me
    render json: current_user.as_profile_json
  end

  def update_profile
    if current_user.update(merge_first_row(user_params, params[:images]))
      render json: current_user.as_profile_json
    else
      render json: current_user.errors, status: :unprocessable_entity
    end
  end

  def update_user_location
    current_user.update_location(params[:current_latitude], params[:current_longitude])
  end

  def set_locale_language
    I18n.locale = params[:locale].present? ? params[:locale].to_sym : :nn
  end

  private
  # Only allow a trusted parameter "white list" through.
  def user_params
    params.permit(
      :first_name,
      :last_name,
      :email,
      :telephone,
      :username,
      :profession_id,
      :password,
      :green_distance_scope,
      :yellow_distance_scope,
      :red_distance_scope,
      :notification_status,
      :notification_status_green,
      :notification_status_yellow,
      :notification_status_red,
      :image_type,
      :image_path
    )
  end
end
