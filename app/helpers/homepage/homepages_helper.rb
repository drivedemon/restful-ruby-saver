module Homepage::HomepagesHelper
  def color_to_level(color_type)
    case color_type.to_sym
    when :green
      :normal
    when :yellow
      :assistance
    when :red
      :urgent
    end
  end
end
