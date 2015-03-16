class CheckLogsJob
  def do_interesting_things
    begin
      ::ClientActivityHistory.where('created_at < ?', 1.week.ago).delete_all
    rescue Exception => e
      ::Log.exception e
    end

    begin
      ::DriverActivityHistory.where('created_at < ?', 2.month.ago).delete_all
    rescue Exception => e
      ::Log.exception e
    end

    begin
      ::DriverCarHistory.where('created_at < ?', 2.month.ago).delete_all
    rescue Exception => e
      ::Log.exception e
    end

    begin
      ::Gcm::Notification.where('sent_at < ?', 10.days.ago).delete_all
    rescue Exception => e
      ::Log.exception e
    end

    begin
      ::DriverRequestHistory.where('created_at < ?', 2.month.ago).delete_all
    rescue Exception => e
      ::Log.exception e
    end

    begin
      ::EmailsPull.where('created_at < ?', 2.month.ago).delete_all
    rescue Exception => e
      ::Log.exception e
    end

    begin
      ::SmsMessagesPull.where('created_at < ?', 2.month.ago).delete_all
    rescue Exception => e
      ::Log.exception e
    end

    begin
      ::Log.where('created_at < ?', 2.month.ago).delete_all
    rescue Exception => e
      ::Log.exception e
    end

    begin
      ::ActiveRecord::Base.connection.execute("DELETE FROM `delayed_jobs` WHERE run_at < \"#{2.day.ago}\"")
    rescue Exception => e
      ::Log.exception e
    end


    self.delay(:run_at => 1.day.from_now).do_interesting_things
  end

  def self.start_me_up
    new.do_interesting_things
  end
end