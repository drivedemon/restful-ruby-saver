class Api::User::HistoriesController < Api::User::ApplicationController
  before_action :set_only_offer_requests_confirmed_help_request, only: [:index]
  before_action :set_offer_request, only: [:index]

  def index
    render json: {
      help_requests: @help_requests,
      offer_requests: @offer_requests
    }
  end

  private
  def set_only_offer_requests_confirmed_help_request
    @help_requests = current_user.help_requests.without_pending_status

    @help_requests = @help_requests.map do |help_request|
      help_request&.as_help_request_format(current_user, true)
    end.compact
  end

  def set_offer_request
    @offer_requests = current_user.offer_requests.without_pending_status

    @offer_requests = @offer_requests.map do |offer_request|
      next if offer_request.owned_help_request.blank?
      offer_request&.as_offer_request_format(current_user, true)
    end.compact
  end
end
