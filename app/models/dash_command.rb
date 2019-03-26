class DashCommand < OpenStruct
  PARSER = /(?<service>\w+)(\s+for (?<time_value>\d+) (?<time_unit>\w+))?/i

  def service
    matched_data[:service] || "api"
  end

  def time_unit
    matched_data[:time_unit] || "minutes"
  end

  def time_value
    (matched_data[:time_value] || 30).to_i
  end

  def to_s
    "#{user_name} is requesting to #{command} #{service} for #{time_value} #{time_unit}"
  end

  def valid?
    !service.blank? && valid_time_units.include?(time_unit)
  end

  # seconds returns the number of seconds that the command wants
  # to lock the service for. This is an absolute value. Not an unix
  # timestamp or anything similar.
  def seconds
    seconds = time_value * 60 # default to minutes
    seconds *= 60 if time_unit == "hours"
    seconds
  end

  private

  def valid_time_units
    %w(minutes hours)
  end

  def matched_data
    @matched_data ||= begin
      PARSER.match(text) || Hash.new
    end
  end
end
