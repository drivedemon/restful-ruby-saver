class Api::Validate::UrgentsController < Api::User::ApplicationController
    def index
        help_requests = current_user.help_requests.filter_by_past_date(
          Time.now.utc.beginning_of_day
        ).with_urgent_request_today
        is_used = help_requests.blank? ? false : true
        render json: { is_used: is_used }
    end
end
