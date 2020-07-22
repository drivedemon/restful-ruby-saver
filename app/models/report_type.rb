class ReportType < Struct.new(:type_ids)
  def initialize(type_ids)
    @sentenses = type_ids.map do |type_id, id|
      case type_id.to_sym
      when :spam
        {
          id: 1,
          type_id: "It’s suspicious or spam"
        }
      when :pretending
        {
          id: 2,
          type_id: "They’re pretending to be someone else"
        }
      when :hateful
        {
          id: 3,
          type_id: "They’re expressing harmful or hateful content"
        }
      when :other
        {
          id: 4,
          type_id: "Others"
        }
      end
    end
  end

  def sentenses
    @sentenses
  end
end
