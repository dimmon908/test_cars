class CheckFutureJob
  def do_interesting_things
    Request::where("`status` = ? and `date` < ? and `comment` like ?", :instant, (Time.now + 25.minute), "%FUTURE:%").all.each do |request|
      request.future_request_not_responded_to_sms
    end


    self.delay(:run_at => 5.minute.from_now).do_interesting_things
  end

  def self.start_me_up
    new.do_interesting_things
  end
end