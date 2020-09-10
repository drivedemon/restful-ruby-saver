class ReportType < Struct.new(:type_ids)
  def initialize(type_ids)
    @sentenses = type_ids.map do |type_id, id|
      case type_id.to_sym
      when :spam
        {
          id: 1,
          type_id: I18n.t("notification_mobile.report_type.spam")
        }
      when :pretending
        {
          id: 2,
          type_id: I18n.t("notification_mobile.report_type.pretending")
        }
      when :hateful
        {
          id: 3,
          type_id: I18n.t("notification_mobile.report_type.hateful")
        }
      when :other
        {
          id: 4,
          type_id: I18n.t("notification_mobile.report_type.others")
        }
      end
    end
  end

  def sentenses
    @sentenses
  end
end
