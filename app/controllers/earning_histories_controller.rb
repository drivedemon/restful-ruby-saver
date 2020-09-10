class EarningHistoriesController < ApplicationController
  before_action :query_index, only: [:index, :export_csv]

  include ExportCsv
  include PageRecordCount
  include FilterParameter
  include QueryCustomerInformation

  def index
    page_number = get_page_parameter(permitted_page_params: permitted_page_params)
    @earning_histories = query_with_params(
      collection_record: @earning_histories,
      permitted_filter_params: permitted_filter_params,
      permitted_order_params: permitted_order_params
    )
    @earning_histories = @earning_histories.paginate(page: page_number, per_page: 10)
    @total_earning_histories_count = total_record_count(
      page_number: page_number,
      current_count: @earning_histories.total_entries,
      collection_record: @earning_histories
    )

    respond_to do |format|
      format.js { render layout: false }
      format.html
    end
  end


  def export_csv
    help_requests = get_data_csv(collection_record: @earning_histories, parameter_ids: params[:ids])
    help_requests = query_with_params(
      collection_record: help_requests,
      permitted_filter_params: permitted_filter_params
    )

    respond_to do |format|
      format.csv {
        send_data HelpRequest.generate_to_csv(
          header: HelpRequest::EARNING_HEADER_CSV,
          column: HelpRequest::EARNING_COLUMN_CSV,
          records: help_requests,
          data_type: HelpRequest::EARNING_HISTORY_HEADER_TYPE
        ),
        filename: HelpRequest::CSV_FILE_NAME % HelpRequest::HEADER_FILE_NAME[2],
        disposition: HelpRequest::ATTACHMENT_TYPE
      }
    end
  end

  private

  def query_index
    @earning_histories = own_earning_history
    return @earning_histories unless is_filter_date?(permitted_date_params: payment_filter_params)

    @earning_histories = @earning_histories.payment_within_range(payment_filter_params[:start_date], payment_filter_params[:end_date])
  end

  def permitted_page_params
    params.permit(
      :page
    )
  end

  def permitted_filter_params
    params.permit(
      :status,
      :amount
    )
  end

  def payment_filter_params
    params.permit(
      :start_date,
      :end_date
    )
  end

  def permitted_order_params
    params.permit(
      :order,
      :order_by
    )
  end
end
