# app/logic/time_to_human_word.rb
module TimeToHumanWord
  module_function
  def calculator_time_to_human_word(created_at)
    diff_seconds = Time.zone.now - created_at
    case diff_seconds
    when 0 .. 59
      "#{(diff_seconds).to_i} seconds ago"
    when 60 .. (3600-1)
      "#{(diff_seconds/60).to_i} minutes ago"
    when 3600 .. (3600*24-1)
      "#{(diff_seconds/3600).to_i} hours ago"
    when (3600*24) .. (3600*24*2-1)
      "#{(diff_seconds/(3600*24)).to_i} day ago"
    when (3600*24) .. (3600*24*30)
      "#{(diff_seconds/(3600*24)).to_i} days ago"
    else
      created_at.strftime("%m/%d/%Y")
    end
  end
end
