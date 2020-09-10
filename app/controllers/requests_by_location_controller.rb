class RequestsByLocationController < ApplicationController
  before_action :query_index, only: [:index, :export_csv]

  include ExportCsv
  include PageRecordCount
  include FilterParameter

  def index
    page_number = get_page_parameter(permitted_page_params: permitted_page_params)
    @help_requests = query_with_params(
      collection_record: @help_requests,
      permitted_filter_params: permitted_filter_params
    )
    @help_requests = @help_requests.paginate(page: page_number, per_page: 10)
    @total_requests_count = total_record_count(
      page_number: page_number,
      current_count: @help_requests.total_entries,
      collection_record: @help_requests
    )

    respond_to do |format|
      format.js { render layout: false }
      format.html
    end
  end

  def destroy
    if @help_request.destroy
      redirect_to requests_path, flash: {success: "Request successfully deleted"}
    else
      error_message = @help_request.errors.messages.map{ |atr, msg| "#{atr} : #{msg.first}" }.join("<br />")
      redirect_to @help_request, flash: {error: error_message}
    end
  end

  def export_csv
    help_requests = get_data_csv(collection_record: @help_requests, parameter_ids: params[:ids])
    help_requests = query_with_params(
      collection_record: help_requests,
      permitted_filter_params: permitted_filter_params
    )

    respond_to do |format|
      format.csv {
        send_data HelpRequest.generate_to_csv(
          header: HelpRequest::REQUEST_LOCATION_HEADER_CSV,
          column: HelpRequest::REQUEST_LOCATION_COLUMN_CSV,
          records: help_requests,
          data_type: HelpRequest::REQUEST_HISTORY_HEADER_TYPE
        ),
        filename: HelpRequest::CSV_FILE_NAME % HelpRequest::HEADER_FILE_NAME[3],
        disposition: HelpRequest::ATTACHMENT_TYPE
      }
    end
  end

  private

  def query_index
    @help_requests = HelpRequest.includes(:user).with_deleted
  end

  def set_help_request
    @help_request = HelpRequest.find(params[:id])
  end

  def permitted_filter_params
    params.permit(
      :location,
      :level,
      :status,
      :start_date,
      :end_date,
      :radius
    )
  end

  def permitted_page_params
    params.permit(
      :page
    )
  end

  def from_notification_params
    params.permit(
      :from_notification
    )
  end
end
