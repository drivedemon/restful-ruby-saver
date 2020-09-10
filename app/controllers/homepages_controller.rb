class HomepagesController < ApplicationController
  def index
    @total_active_user = User.active.filter_by_past_date(
      filter_params(model_name: User)
    ).count

    @total_revenue = Payment.filter_by_past_date(
      filter_params(model_name: Payment)
    ).sum(:amount)

    @total_requests = HelpRequest.filter_by_past_date(
      filter_params(model_name: HelpRequest)
    ).count

    @tolal_green_requests = HelpRequest.color_status_green.filter_by_past_date(
      filter_params(model_name: HelpRequest)
    ).count

    @tolal_yellow_requests = HelpRequest.color_status_yellow.filter_by_past_date(
      filter_params(model_name: HelpRequest)
    ).count

    @tolal_red_requests = HelpRequest.color_status_red.filter_by_past_date(
      filter_params(model_name: HelpRequest)
    ).count

    @top_requests = HelpRequest.unscoped.sort_by_top_amount.filter_by_past_date(
      filter_params(model_name: HelpRequest)
    ).limit(5)

    @top_users = OfferRequest.unscoped.filter_by_past_date(
      filter_params(model_name: OfferRequest)
    ).sort_by_top_user.limit(5).count

    respond_to do |format|
      format.js { render layout: false }
      format.html
    end
  end

  private

  def filter_params(model_name: nil)
    time = params[:time].present? ? params[:time] : "month"
    case time.to_sym
    when :all
      model_name.minimum(:created_at)
    when :year
      1.years.ago
    else
      30.days.ago
    end
  end
end
