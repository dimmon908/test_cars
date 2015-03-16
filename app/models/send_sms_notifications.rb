class SendSmsNotifications
  def do_interesting_things
    begin
      SmsMessagesPull::deliver
    rescue Exception => e
      Log.exception e
    end

    self.delay(:run_at => 1.minute.from_now).do_interesting_things
  end

  def self.start_me_up
    new.do_interesting_things
  end
end