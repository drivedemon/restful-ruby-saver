class Api::User::NotificationSettingController <  Api::User::ApplicationController
  before_action :set_params_notifications_disable, only: [:update]

  def update
    if current_user.update(user_notification_params)
      render json: { success: true }, status: :ok
    else
      render json: current_user.errors, status: :unprocessable_entity
    end

  end

  def reset
    if current_user.update(set_default_user_notification_params)
      render json: { success: true }, status: :ok
    else
      render json: current_user.errors, status: :unprocessable_entity
    end
  end

  def clear
    if params[:type] == 'notification'
      current_user.notifications.read_all!(current_user)
    else
      current_user.other_user_chats_self_help_request.read_all!(current_user)
      current_user.other_user_chats_self_offer_request.read_all!(current_user)
    end

    render json: { success: true }, status: :ok
  end

  private
  def set_params_notifications_disable
    unless params[:notification_status]
      params[:notification_status_green] = false
      params[:notification_status_yellow] = false
      params[:notification_status_red] = false
    end
  end

  def set_default_user_notification_params
    {
      green_distance_scope: 50,
      yellow_distance_scope: 50,
      red_distance_scope: 50,
      notification_status: true,
      notification_status_green: true,
      notification_status_yellow: true,
      notification_status_red: true
    }
  end

  def user_notification_params
    params.permit(
      :green_distance_scope,
      :yellow_distance_scope,
      :red_distance_scope,
      :notification_status,
      :notification_status_green,
      :notification_status_yellow,
      :notification_status_red
    )
  end
end
