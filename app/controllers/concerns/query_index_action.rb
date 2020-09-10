require 'active_support/concern'

module QueryIndexAction
  extend ActiveSupport::Concern

  def own_request_offer_history(model:, model_key:, user_id:)
    collection_model = case model_key
    when :help_request
      model.includes(:user, :offer_requests)
    when :offer_request
      model.includes(:user, :owned_help_request)
    end
    collection_model.where(user_id: user_id)
  end

  def own_earning_history(user_id:)
    HelpRequest.includes(:user, [offer_requests: :user], :payment)
      .where("offer_requests.helpee_request_status_id != 1
        AND offer_requests.helper_request_status_id != 1
        AND payments.help_request_id IS NOT NULL
        AND offer_requests.user_id = ?", user_id)
      .references(:offer_requests, :payment)
  end

  def own_spending_history(user_id:)
    HelpRequest.includes(:user, :payment).where(is_paid: true, user_id: user_id)
  end

end
