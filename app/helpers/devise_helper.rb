module DeviseHelper
  def devise_error_messages!
    return "" if resource.errors.empty?
    messages = resource.errors.full_messages.map { |msg| content_tag(:div, msg) }.join
    flash.now[:error] = messages.html_safe
  end
end