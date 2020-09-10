class CustomersController < ApplicationController
  before_action :query_index, only: [:index, :export_csv]
  before_action :set_user, except: [:index, :export_csv]
  before_action :selected_collection_customer, only: [:export_csv_information]
  before_action(except: [:index, :export_csv]) { updated_read_at_notification(from_notification_params: from_notification_params) }

  include ExportCsv
  include FilterParameter
  include PageRecordCount
  include QueryIndexAction
  include DashboardNotificationTrigger
  include QueryCustomerInformation

  def index
    page_number = get_page_parameter(permitted_page_params: permitted_page_params)
    @users = query_with_params(
      collection_record: @users,
      permitted_filter_params: permitted_filter_params
    )
    @users = @users.paginate(page: page_number, per_page: 10)
    @total_users_count = total_record_count(
      page_number: page_number,
      current_count: @users.total_entries,
      collection_record: @users
    )

    respond_to do |format|
      format.js { render layout: false }
      format.html
    end
  end

  def request_history
    page_number = get_page_parameter(permitted_page_params: permitted_page_params)
    @help_request_histories = own_request_offer_history(
      model: HelpRequest,
      model_key: HelpRequest.name.underscore.downcase.to_sym,
      user_id: @user.id
    )
    @help_request_histories = @help_request_histories.paginate(page: page_number, per_page: 10)
    respond_to do |format|
      format.js { render partial: 'customer_help_request_history.js.erb', layout: false }
      format.html
    end
  end

  def offer_history
    page_number = get_page_parameter(permitted_page_params: permitted_page_params)
    @offer_request_histories = own_request_offer_history(
      model: OfferRequest,
      model_key: OfferRequest.name.underscore.downcase.to_sym,
      user_id: @user.id
    )
    @offer_request_histories = @offer_request_histories.paginate(page: page_number, per_page: 10)
    respond_to do |format|
      format.js { render partial: 'customer_offer_request_history.js.erb', layout: false }
      format.html
    end
  end

  def earning_history
    page_number = get_page_parameter(permitted_page_params: permitted_page_params)
    @earning_histories = own_earning_history(user_id: @user.id)
    @earning_histories = @earning_histories.paginate(page: page_number, per_page: 10)
    respond_to do |format|
      format.js { render partial: 'customer_earning_history.js.erb', layout: false }
      format.html
    end
  end

  def spending_history
    page_number = get_page_parameter(permitted_page_params: permitted_page_params)
    @spending_histories = own_spending_history(user_id: @user.id)
    @spending_histories = @spending_histories.paginate(page: page_number, per_page: 10)
    respond_to do |format|
      format.js { render partial: 'customer_spending_history.js.erb', layout: false }
      format.html
    end
  end

  def export_csv
    respond_to do |format|
      format.csv {
        send_data User.generate_to_csv(
          header: User::HEADER_CSV,
          column: User::COLUMN_CSV,
          records: get_data_csv(collection_record: @users, parameter_ids: params[:ids]),
          data_type: User::HEADER_TYPE
        ),
        filename: User::CSV_FILE_NAME % User::HEADER_FILE_NAME[0],
        disposition: User::ATTACHMENT_TYPE
      }
    end
  end

  def export_csv_information
    custom_file_name = "#{params[:export_type]}-user-#{@user.id}"
    respond_to do |format|
      format.csv {
        send_data User.generate_to_csv(
          header: @selected_header,
          column: @selected_column,
          records: @selected_record,
          data_type: @selected_type
        ),
        filename: User::CSV_FILE_NAME % custom_file_name,
        disposition: User::ATTACHMENT_TYPE
      }
    end
  end

  def edit
    initialize_form_data("edit")
  end

  def update
    @user = User.find(params[:id])
    if @user.update(customer_params.reject{|_, v| v.blank?})
      store_image_data
      redirect_to request_history_customers_path(@user), flash: {success: "Customer successfully updated"}
    else
      error_message = @user.errors.messages.map{ |atr, msg| "#{atr} : #{msg.first}" }.join("<br />")
      redirect_to edit_customers_path(@user), flash: {error: error_message}
    end
  end

  def destroy
    status = @user.status.to_sym == :banned ? :active : :banned
    if @user.update(status: status)
      redirect_to customers_path, flash: {success: status == :banned ? "User successfully banned" : "User successfully unbanned" }
    else
      error_message = @user.errors.messages.map{ |atr, msg| "#{atr} : #{msg.first}" }.join("<br />")
      redirect_to @user, flash: {error: error_message}
    end
  end

  private

  def selected_collection_customer
    case params[:export_type].to_sym
    when :request_history
      @selected_header = HelpRequest::REQUEST_HEADER_CSV
      @selected_column = HelpRequest::REQUEST_COLUMN_CSV
      @selected_record = own_request_offer_history(
        model: HelpRequest,
        model_key: HelpRequest.name.underscore.downcase.to_sym,
        user_id: @user.id
      )
      @selected_type = HelpRequest::REQUEST_HISTORY_HEADER_TYPE
    when :offer_history
      @selected_header = OfferRequest::OFFER_HEADER_CSV
      @selected_column = OfferRequest::OFFER_COLUMN_CSV
      @selected_record = own_request_offer_history(
        model: OfferRequest,
        model_key: OfferRequest.name.underscore.downcase.to_sym,
        user_id: @user.id
      )
      @selected_type = OfferRequest::HEADER_TYPE[0]
    when :earning_history
      @selected_header = HelpRequest::EARNING_HEADER_CSV
      @selected_column = HelpRequest::EARNING_COLUMN_CSV
      @selected_record = own_earning_history(user_id: @user.id)
      @selected_type = HelpRequest::EARNING_HISTORY_HEADER_TYPE
    when :spending_history
      @selected_header = HelpRequest::SPENDING_HEADER_CSV
      @selected_column = HelpRequest::SPENDING_COLUMN_CSV
      @selected_record = own_spending_history(user_id: @user.id)
      @selected_type = HelpRequest::SPENDING_HISTORY_HEADER_TYPE
    end
  end

  def set_user
    @user = User.includes(:rates, :profession).find(params[:id])
  end

  def query_index
    @users ||= User.left_joins(:help_requests, :offer_requests_accepted)
      .group("users.id")
      .select(
        "users.id,
        users.image_path,
        users.first_name,
        users.last_name,
        users.email,
        users.status,
        users.created_at,
        COALESCE(SUM(help_requests.price),0) as total_spending,
        COALESCE(SUM(offer_requests_accepteds_users.price),0) as total_earning,
        COUNT(help_requests.id) as total_request"
      ).order("users.created_at DESC")
  end

  def permitted_filter_params
    params.permit(
      :amount,
      :status,
      :start_date,
      :amount_earning,
      :amount_spending,
      :end_date,
      :name
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

  def initialize_form_data(action_called)
    @user = User.find(params[:id])
    @professions = Profession.all
  end

  def customer_params
    params.require(:user).permit(:first_name, :last_name, :avatar, :username, :email, :profession_id)
  end

  def store_image_data
    if customer_params[:avatar]
      make_image_public(@user.avatar.key)
      @user.update(image_type: @user.avatar.content_type, image_path: @user.avatar.service_url.sub(/\?.*/, ''))
    end
  end

  def make_image_public(key)
    S3_CLIENT.put_object_acl(
      bucket: Rails.application.credentials[:aws][:bucket_name],
      key: key,
      acl: "public-read"
    )
  end
end
