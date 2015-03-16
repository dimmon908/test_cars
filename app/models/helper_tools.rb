class HelperTools
  JS_DATE = '%Y-%m-%dT%H:%M:%S%:z'
  DATE_FORMAT = '%Y-%m-%d'
  JS_DATE_FORMAT = '%m/%d/%Y'

  def self.format_time(time)
    hours = (time/3600).to_i
    if hours.to_i > 0
      time = time - hours*3600
      minutes = (time/60).to_i
      time = time - 60*minutes

      seconds = time.to_i
      ":#{hours.to_s.rjust(2, '0')}#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
    else
      minutes = (time/60).to_i
      time = time.to_i - 60*minutes

      seconds = time.to_i
      "#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
    end
  end

  def self.meters_to_miles metrs
    (0.000621371192 * metrs.to_f).round 1
  end
  def self.miles_to_meters miles
    (1609.344 * miles.to_f).round 1
  end

  def self.to_minutes seconds
    (seconds.to_i/60).round
  end

  def self.to_hours seconds
    (seconds.to_i/3600).round
  end

  def self.datetime date
    date ||= ''
    if date.is_a?String
      if date.to_s =~ Request::TIME_STAMP_REGEXP
        return Time.strptime(date, Request::TIME_STAMP_FORMAT)
      elsif date.to_s =~ Request::DB_DATE_REGEXP
        return Time.strptime(date, Request::DB_DATE_FORMAT)
      elsif date.to_s =~ Request::DATE_REGEXP
        return Time.strptime(date, Request::DATE_FORMAT)
      end
    end
    date
  end

end