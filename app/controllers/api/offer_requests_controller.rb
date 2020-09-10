class Api::OfferRequestsController < Api::User::ApplicationController
  after_action :create_chat_by_status, only: [:update]
  before_action :set_offer_request_show, only: [:show]
  before_action :set_offer_request, only: [:update, :destroy]

  # GET /api/offer_requests
  def index
    @offer_requests = OfferRequest.all

    render json: @offer_requests.map{ |res| res.as_offer_request_format(current_user) }
  end

  # GET /api/offer_requests/1
  def show
    render json: @offer_request
  end

  # POST /api/offer_requests
  def create
    @offer_request = OfferRequest.new(offer_request_params.merge({
      helpee_request_status_id: OfferRequest::PENDING_STATUS,
      helper_request_status_id: OfferRequest::PENDING_STATUS,
      user_id: current_user[:id]
      })
    )
    if @offer_request.save
      render json: @offer_request, status: :created
    else
      render json: @offer_request.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/offer_requests/1
  def update
    if @offer_request.update(offer_request_params)
      render json: @offer_request
    else
      render json: @offer_request.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/offer_requests/1
  def destroy
    OfferRequest.create_notify_history(
      action_type: :offer_request,
      receive_id: @offer_request.help_request.user_id,
      chat_model: nil,
      offer_request_model: @offer_request
    )
    @offer_request.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def define_status_id
    params[:helpee_request_status_id] || params[:helper_request_status_id]
  end

  def create_chat_by_status
    return create_reverse_notify if validate_status?(:reverse) || validate_status?(:reject)
    return unless [OfferRequest::CONFIRM_STATUS, OfferRequest::COMPLETE_STATUS].include? define_status_id

    chat_type = validate_status?(:confirm) ? AcceptChat::MESSAGE : ConfirmChat::MESSAGE
    @chat = Chat.create(type: chat_type, chat_room_id: @offer_request.chat_room.id, is_read: true, user_id: current_user[:id])

    if params[:helper_request_status_id].present?
      reject_offer_after_confirm if validate_status?(:confirm)
      update_help_request_status
      return OfferRequest.create_notify_history(
        action_type: :chat,
        receive_id: @offer_request.help_request.user_id,
        chat_model: @chat,
        offer_request_model: nil
      )
    end

    OfferRequest.create_notify_history(
      action_type: :chat,
      receive_id: @offer_request.user_id,
      chat_model: @chat,
      offer_request_model: nil
    )
  end

  def create_reverse_notify
    force_user = validate_status?(:reverse) ? @offer_request.user : @offer_request.owned_help_request_user

    OfferRequest.notify_pusher(
      help_request_id: @offer_request.help_request_id,
      event_name: validate_status?(:reverse) ? "cancel-accept-offer" : "decline-accept-help"
    )
    @offer_request.notifications.create(user_id: force_user.id, is_offer_rejected: true)
  end

  def validate_status?(status_type)
    case status_type
    when :confirm
      define_status_id == OfferRequest::CONFIRM_STATUS
    when :reverse
      define_status_id == OfferRequest::PENDING_STATUS
    when :reject
      define_status_id == OfferRequest::REJECT_STATUS
    end
  end

  def reject_offer_after_confirm
    reject_list = OfferRequest.without_confirm_status(@offer_request)
    reject_list.each { |reject_offer| reject_offer&.destroy }
  end

  def update_help_request_status
    help_request_status = validate_status?(:confirm) ? HelpRequest.statuses[:confirmed] : HelpRequest.statuses[:completed]
    @offer_request.help_request.update(status: help_request_status)
  end

  def set_offer_request
    @offer_request = OfferRequest.find(params[:id])
  end

  # Use callbacks to setup show method.
  def set_offer_request_show
    @offer_request = OfferRequest.find(params[:id]).as_offer_request_format(current_user)
  end

  # Only allow a trusted parameter "white list" through.
  def offer_request_params
    params.permit(:description, :helpee_request_status_id, :helper_request_status_id, :help_request_id, :latitude, :longitude, :user_id)
  end
end
