class RequestsController < ApplicationController
  before_action :query_index, only: [:index, :export_csv]
  before_action :set_help_request, only: [:show, :destroy, :export_csv_information]
  # before_action :set_report_history, only: [:show, :export_csv_information]
  before_action(only: [:show]) { updated_read_at_notification(from_notification_params: from_notification_params) }

  include ExportCsv
  include PageRecordCount
  include FilterParameter
  include DashboardNotificationTrigger

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

  def show
    @help_request
  end

  def destroy
    @help_request.update_columns(status: :cancelled)
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
          header: HelpRequest::REQUEST_HEADER_CSV,
          column: HelpRequest::REQUEST_COLUMN_CSV,
          records: help_requests,
          data_type: HelpRequest::REQUEST_HISTORY_HEADER_TYPE
        ),
        filename: HelpRequest::CSV_FILE_NAME % HelpRequest::HEADER_FILE_NAME[0],
        disposition: HelpRequest::ATTACHMENT_TYPE
      }
    end
  end

  def export_csv_information
    custom_file_name = "#{params[:export_type]}-user-#{@help_request.user_id}"
    respond_to do |format|
      format.csv {
        send_data HelpRequest.generate_to_csv(
          header: HelpRequest::REQUEST_INFORMATION_HEADER_CSV,
          column: HelpRequest::REQUEST_INFORMATION_COLUMN_CSV,
          records: @help_request,
          data_type: HelpRequest::HEADER_TYPE,
          information_header: User::INFORMATION_HEADER_CSV,
          information_column: User::INFORMATION_COLUMN_CSV,
          information_data: @help_request.user
        ),
        filename: HelpRequest::CSV_FILE_NAME % custom_file_name,
        disposition: HelpRequest::ATTACHMENT_TYPE
      }
    end
  end

  private

  def query_index
    @help_requests = HelpRequest.includes(:user).with_deleted
  end

  def set_help_request
    @help_request = HelpRequest.includes(:image_help_requests, :user => :profession).with_deleted.find(params[:id])
  end

  def permitted_filter_params
    params.permit(
      :level,
      :amount,
      :status,
      :start_date,
      :end_date
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
