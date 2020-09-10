class Api::ReportsController <  Api::User::ApplicationController
  include DashboardNotificationTrigger

  def index
    render json: ReportType.new(Report.type_ids).sentenses
  end

  def create
    report = Report.new(report_params)
    if report.save
      store_and_trigger_notification_job(:user_reported, {report_id: report.id})
      render json: report, status: :created
    else
      render json: report.errors, status: :unprocessable_entity
    end
  end

  private
  def report_params
    params.permit(:help_request_id, :comment, :offer_request_id, :type_id)
  end
end
