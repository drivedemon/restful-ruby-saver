class Api::NotificationViewsController < Api::User::ApplicationController
  before_action :set_notification, only: [:update]
  after_action :set_notification, only: [:update]
  before_action :trigger_remove_notification, only: [:update]
  before_action :set_notification_show, only: [:index]

  def index
    render json: @notifications
  end

  def update
    if @notification.update(notification_params)
      render json: @notification
    else
      render json: @notification.errors, status: :unprocessable_entity
    end
  end

  def destroy
    notify_pusher(current_user.notifications.count)
    current_user.notifications.destroy_all
    current_user.notifications.with_deleted.destroy_all

    render json: { success: true }, status: :ok
  rescue
    render json: { success: false }, status: :bad_request
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_notification
    @notification = Notification.find(params[:id])
  end

  def trigger_remove_notification
    return if @notification[:is_read] == notification_params[:is_read]
    notify_pusher
  end

  def notify_pusher(count_data = nil)
    Pusher.trigger("user-#{current_user.id}", "remove-notifications", count_data)
  end

  # Use callbacks to setup show method.
  def set_notification_show
    @notifications = Notification.with_current_user(current_user[:id], params[:page])
    @notifications = @notifications.map{ |noti|
      noti.as_notification_format(current_user)
    }
  end

  # Only allow a trusted parameter "white list" through.
  def notification_params
    params.permit(:is_read)
  end
end
