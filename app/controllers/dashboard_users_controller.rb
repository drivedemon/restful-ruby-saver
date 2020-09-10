class DashboardUsersController < ApplicationController
  include PageRecordCount
  include FilterParameter

  around_action :catch_not_found

  def index
    @dashboard_users = DashboardUser.includes(:role).with_attached_avatar
    page_number = get_page_parameter(permitted_page_params: permitted_page_params)
    @dashboard_users = query_with_params(
      collection_record: @dashboard_users,
      permitted_filter_params: permitted_filter_params,
      permitted_order_params: permitted_order_params
    )
    @dashboard_users = @dashboard_users.paginate(page: page_number, per_page: 10)
    @total_dashboard_users_count = total_record_count(
      page_number: page_number,
      current_count: @dashboard_users.total_entries,
      collection_record: @dashboard_users
    )
    @roles ||= Role.all

    respond_to do |format|
      format.js { render layout: false }
      format.html
    end
  end

  def show
    @dashboard_user = DashboardUser.includes(:role).find(params[:id])
  end

  def new
    initialize_form_data("new")
  end

  def create
    @dashboard_user = DashboardUser.new(dashboard_user_params)
    if @dashboard_user.save
      DashboardMailer.welcome_email(@dashboard_user, dashboard_user_params["password"]).deliver_later
      redirect_to @dashboard_user, flash: {success: "User successfully created"}
    else
      error_message = @dashboard_user.errors.messages.map{ |atr, msg| "#{atr} : #{msg.first}" }.join("<br />")
      redirect_to new_dashboard_user_path, flash: {error: error_message}
    end
  end

  def edit
    initialize_form_data("edit")
  end

  def update
    @dashboard_user = DashboardUser.find(params[:id])
    #reject empty password fields
    if @dashboard_user.update(dashboard_user_params.reject{|_, v| v.blank?})
      redirect_to @dashboard_user, flash: {success: "User successfully updated"}
    else
      error_message = @dashboard_user.errors.messages.map{ |atr, msg| "#{atr} : #{msg.first}" }.join("<br />")
      redirect_to edit_dashboard_users_path(@dashboard_user), flash: {error: error_message}
    end
  end

  def destroy
    @dashboard_user = DashboardUser.find(params[:id])
    if @dashboard_user.destroy
      redirect_to dashboard_users_path, flash: {success: "User successfully deleted"}
    else
      error_message = @dashboard_user.errors.messages.map{ |atr, msg| "#{atr} : #{msg.first}" }.join("<br />")
      redirect_to @dashboard_user, flash: {error: error_message}
    end
  end

private
  def permitted_filter_params
    params.permit(
      :role_id,
      :start_date,
      :end_date,
      :name
    )
  end

  def permitted_order_params
    params.permit(
      :order,
      :order_by
    )
  end

  def permitted_page_params
    params.permit(
      :page
    )
  end

  def dashboard_user_params
    params.require(:dashboard_user).permit(:first_name, :last_name, :email,
      :username, :password, :password_confirmation, :role_id, :receive_notification,
      :dashboard_language, :avatar)
  end

  def catch_not_found
    yield
  rescue ActiveRecord::RecordNotFound
    redirect_to authenticated_root_path, :flash => { :error => "Record not found." }
  end

  def initialize_form_data(action_called)
    @dashboard_user = action_called == "new" ? DashboardUser.new : DashboardUser.find(params[:id])
    @roles = Role.all
    @available_languages = I18n.available_locales.map(&:to_s)
    @receive_notification = action_called == "new" ? nil : @dashboard_user.receive_notification
    @dashboard_language = action_called == "new" ? nil : @dashboard_user.dashboard_language
    @password_required = action_called == "new" ? true : false
  end
end
