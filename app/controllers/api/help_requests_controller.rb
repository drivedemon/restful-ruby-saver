class Api::HelpRequestsController <  Api::User::ApplicationController
  after_action :add_request_view_after_show, only: [:show]
  before_action :set_help_request_show, only: [:show]
  before_action :set_help_request, only: [:update, :destroy]
  before_action :update_help_request_status, only: [:destroy]

  include MergeImageParam
  include DashboardNotificationTrigger

  # GET /help_requests
  def index
    @help_requests = if params[:is_owner] == "true"
      current_user.help_requests.select do |help_request|
        help_request.offer_requests.joins(:rates).blank?
      end.flatten
    elsif params[:is_owner] == "false"
      HelpRequest.with_pending_status.without_current_user(current_user.id)
    else
      HelpRequest.with_pending_status
    end

    @help_requests = @help_requests.select do |help_request|
      help_request.check_user_in_distance(current_user)
    end unless params[:is_owner] == "true"

    @help_requests_json = @help_requests.map do |help_request|
      help_request.as_help_request_format(current_user, true)
    end

    case params[:sort_by]
    when HelpRequest::REQUEST_RANGE_DISTANCE
      render json: @help_requests_json.sort_by{ |e| e[:distance] }
    when HelpRequest::REQUEST_RANGE_URGENT
      render json: @help_requests_json.sort_by{ |e| -e[:color_status_id] }
    else
      render json: @help_requests_json
    end
  end

  # GET /help_requests/1
  def show
    render json: @help_request
  end

  # POST /help_requests
  def create
    @help_request = HelpRequest.new(help_request_params.merge(
        {
          status: HelpRequest.statuses[:pending],
          user_id: current_user.id
        }
      )
    )
    if @help_request.save
      add_or_remove_image_related_model(@help_request.image_help_requests, params[:images])
      store_and_trigger_notification_job(:new_help_request, {new_request_id: @help_request.id})
      render json: @help_request, status: :created
    else
      render json: @help_request.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /help_requests/1
  def update
    if @help_request.update(help_request_params.merge(
        {
          status: HelpRequest.statuses[:pending],
          user_id: current_user.id
        }
      )
    )
      add_or_remove_image_related_model(@help_request.image_help_requests, params[:images], params[:remove_images])
      render json: @help_request
    else
      render json: @help_request.errors, status: :unprocessable_entity
    end
  end

  # DELETE /help_requests/1
  def destroy
    @help_request.destroy
  end

  private
  def add_request_view_after_show
    return unless @help_request[:user][:id] != current_user.id
    HelpRequestView.where(help_request_id: params[:id], user_id: current_user.id).first_or_create
  end

  def help_request_params
    p = params.permit(:description, :distance_scope, :price, :status, :latitude, :longitude, :color_status, :user_id)
    p.merge(
      {
        color_status: p[:color_status].to_i
      }
    )
  end

  def set_help_request
    @help_request = HelpRequest.find(params[:id])
  end

  def set_help_request_show
    @help_request = HelpRequest.find(params[:id]).as_help_request_format(current_user, true)
  end

  def update_help_request_status
    @help_request.update(status: :cancelled)
  end
end
