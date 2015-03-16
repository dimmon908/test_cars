class SendPushNotifications
  def do_interesting_things
    begin
      Gcm::Notification.send_notifications
    rescue Exception => e
      Log.exception e
    end

    begin
      APN::Notification.send_notifications
    rescue Exception => e
      Log.exception e
    end

    self.delay(:run_at => 1.minute.from_now).do_interesting_things
  end

  def self.start_me_up
    new.do_interesting_things
  end
end