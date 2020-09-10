require 'active_support/concern'

module QueryCustomerInformation
  extend ActiveSupport::Concern

  def own_request_offer_history(model:, model_key:, user_id:)
    collection_record = case model_key
    when :help_request
      model.includes(:user, :offer_requests)
    when :offer_request
      model.includes(:user, :owned_help_request)
    end
    collection_record.where(user_id: user_id)
  end

  def own_earning_history(user_id: nil)
    HelpRequest.includes(:user, [offer_requests: :user], :payment).earning_history(user_id)
  end

  def own_spending_history(user_id: nil)
    HelpRequest.includes(:user, :payment).spending_history(user_id)
  end

  def own_report
    Report.includes(:reported_from, :reported_to)
  end

end
