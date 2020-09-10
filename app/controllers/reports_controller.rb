class ReportsController < ApplicationController
  before_action :query_index, only: [:index, :export_csv]
  before_action :set_report, only: [:show, :destroy, :export_csv_information]
  before_action :set_report_history, only: [:show, :export_csv_information]
  before_action(only: [:show]) { updated_read_at_notification(from_notification_params: from_notification_params) }

  include ExportCsv
  include PageRecordCount
  include FilterParameter
  include DashboardNotificationTrigger
  include QueryCustomerInformation

  def index
    page_number = get_page_parameter(permitted_page_params: permitted_page_params)
    @reports = query_with_params(
      collection_record: @reports,
      permitted_filter_params: permitted_filter_params
    )
    @reported_by ||= @reports.map{ |report| report.reported_from_user }.uniq
    @reports = @reports.paginate(page: page_number, per_page: 10)
    @total_reports_count = total_record_count(
      page_number: page_number,
      current_count: @reports.total_entries,
      collection_record: @reports
    )

    respond_to do |format|
      format.js { render layout: false }
      format.html
    end
  end

  def show
    page_number = get_page_parameter(permitted_page_params: permitted_page_params)
    @report_history = query_with_params(
      collection_record: @report_history,
      permitted_filter_params: permitted_filter_params
    )
    @report_history = @report_history.paginate(page: page_number, per_page: 5)
    respond_to do |format|
      format.js { render 'show.js.erb', layout: false }
      format.html
    end
  end

  def destroy
    if @report.destroy
      redirect_to requests_path, flash: {success: "Report successfully deleted"}
    else
      error_message = @report.errors.messages.map{ |atr, msg| "#{atr} : #{msg.first}" }.join("<br />")
      redirect_to @report, flash: {error: error_message}
    end
  end

  def export_csv
    reports = get_data_csv(collection_record: @reports, parameter_ids: params[:ids])
    reports = query_with_params(
      collection_record: reports,
      permitted_filter_params: permitted_filter_params
    )

    respond_to do |format|
      format.csv {
        send_data Report.generate_to_csv(
          header: Report::REPORT_LIST_HEADER_CSV,
          column: Report::REPORT_LIST_COLUMN_CSV,
          records: reports
        ),
        filename: Report::CSV_FILE_NAME % Report::HEADER_FILE_NAME[0],
        disposition: Report::ATTACHMENT_TYPE
      }
    end
  end

  def export_csv_information
    custom_file_name = "#{params[:export_type]}-user-#{@get_user_id_from_reported.id}"
    respond_to do |format|
      format.csv {
        send_data Report.generate_to_csv(
          header: Report::REPORT_INFORMATION_HEADER_CSV,
          column: Report::REPORT_INFORMATION_COLUMN_CSV,
          records: @report_history,
          data_type: Report::HEADER_TYPE,
          information_header: User::INFORMATION_HEADER_CSV,
          information_column: User::INFORMATION_COLUMN_CSV,
          information_data: @get_user_id_from_reported
        ),
        filename: Report::CSV_FILE_NAME % custom_file_name,
        disposition: Report::ATTACHMENT_TYPE
      }
    end
  end

  private

  def query_index
    @reports = own_report
  end

  def set_report
    @report = own_report.find(params[:id])
  end

  def set_report_history
    @get_user_id_from_reported = @report.reported_to_user
    @report_history = own_report.where(offer_requests: {user_id: @get_user_id_from_reported.id})
  end

  def permitted_filter_params
    params.permit(
      :reason,
      :reported_from_user,
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
