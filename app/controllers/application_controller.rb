class ApplicationController < ActionController::Base
  authorize_resource :class => false, unless: :devise_controller?

  before_action :authenticate_dashboard_user!, unless: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?
  around_action :set_locale_from_url
  before_action :set_time_zone
  before_action :get_all_notifications

  def set_time_zone
    Time.zone = (current_dashboard_user && current_dashboard_user.region) ? current_dashboard_user.region.timezone : "Europe/Oslo"
  end

  def body_class_name
    [
      params[:controller].tr("/", "-"),
      action_name,
      params[:id]
    ].compact.join(" ")
  end
  helper_method :body_class_name

  def set_locale_from_url(&action)
    #set locale as user set language if not explicitly asked in url
    requested_locale = current_dashboard_user.dashboard_language.to_sym if current_dashboard_user.present?

    locale = I18n.available_locales.find { |l| l == requested_locale } ||
      I18n.default_locale

    I18n.with_locale(locale, &action)
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def get_all_notifications
    return unless current_dashboard_user
    @unread_notifications = current_dashboard_user.dashboard_notifications.unread
  end

  def current_ability
    @current_ability ||= ::Ability.new(current_dashboard_user)
  end

  rescue_from CanCan::AccessDenied do |exception|
    I18n.locale = current_dashboard_user.dashboard_language.to_sym if current_dashboard_user.present?
    redirect_to authenticated_root_path, :alert => t("dashboard.permission.not_allowed")
  end

  protected

  def configure_permitted_parameters
    added_attrs = [:login, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_in, keys: added_attrs
  end
end
