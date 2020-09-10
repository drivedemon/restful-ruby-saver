class Api::User::ConversationsController < Api::User::ApplicationController
  before_action :set_offer_requests_related_to_help_request, only: [:index]
  before_action :set_offer_request, only: [:index]

  def index
    render json: {
      offer_requests_related_to_help_requests: @offer_requests_related_to_help_requests,
      offer_requests: @offer_requests
    }
  end

  private
  def set_offer_requests_related_to_help_request
    help_requests = check_parameter(current_user.help_requests)

    @offer_requests_related_to_help_requests = help_requests.map do |help_request|
      offer_with_status = check_parameter(help_request.offer_requests)
      each_data(offer_with_status)
    end.flatten
  end

  def set_offer_request
    owned_offer_requests = current_user.offer_requests.joins(:help_request)
    offer_with_status = check_parameter(owned_offer_requests)

    @offer_requests = each_data(offer_with_status)
  end

  def check_parameter(model)
    if params[:show_all]
      model.with_complete_status
    else
      model.without_complete_status
    end
  end

  def each_data(offer_requests)
    offer_requests.joins(:chat_room).map do |offer_request|
      offer_request&.as_offer_request_format(current_user)
    end.compact
  end
end
