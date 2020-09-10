module ApplicationHelper
  def activeable_tag_for(tag, text, path, options = {})
    content_tag tag, link_to(text, path, options), class: "#{options[:tag_class]}#{' '+options[:class_name] if request.path == path && options[:class_name].present?} "
  end

  def toastr_flash
    flash.each_with_object([]) do |(type, message), flash_messages|
      type = 'success' if type == 'notice'
      type = 'error' if type == 'alert'
      text = "<script>toastr.#{type}('#{message}', '', { closeButton: true, progressBar: true })</script>"
      flash_messages << text.html_safe if message
    end.join("\n").html_safe
  end

  def format_date_view(datetime = DateTime.now)
    datetime.strftime("%b %d, %Y")
  end

  def format_date_time_view(datetime = DateTime.now)
    datetime.strftime("%b %d, %Y %l:%M%P")
  end

  def format_currency(amount)
    "#{amount.to_s} kr"
  end

  def report_type_to_wording(type_id:, other_comment: nil)
    case type_id.to_sym
    when :spam
      t("dashboard.report.report_type.spam")
    when :pretending
      t("dashboard.report.report_type.pretending")
    when :hateful
      t("dashboard.report.report_type.hateful")
    when :other
      other_comment
    end
  end

  def active_class(path)
    return 'active' if request.path == path
  end
end
