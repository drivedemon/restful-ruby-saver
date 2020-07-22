class Api::RatingController < Api::User::ApplicationController
  before_action :set_offer_request, only: [:create]
  before_action :set_rate_show, only: [:show]

  def create
    @rate = Rate.new(rating_params)
    if @rate.save
      render json: @rate, status: :created
    else
      render json: @rate.errors, status: :unprocessable_entity
    end
  end

  def show
    render json: @rate&.as_rate_notification_format(current_user)
  end

  private
  def rating_params
    params.permit(:score, :comment, :user_id, :offer_request_id).merge({ user_id: @offer_request.user.id })
  end

  def set_offer_request
    @offer_request = OfferRequest.find(params[:offer_request_id])
  end

  def set_rate_show
    @rate = Rate.find(params[:id])
  end
end
