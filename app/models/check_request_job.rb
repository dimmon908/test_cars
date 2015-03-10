class CheckRequestJob
  def do_interesting_things
    Request.future.before_date(Time.now + Configurations[:instant_request_time].minute).find_each do |request|
      request.instant! true
    end

    Request.instant.future_flag_0.where('`booked` < ?', (Time.now - Configurations[:cancel_no_fee_time].second)).find_each do |request|
      request.canceled! true
    end

    Request.instant.future_flag_1.where('`date` >= ?',
                   (Time.now + Configurations[:future_request_admin_call_time].minute)
    ).find_each do |request|
      request.notify_admin
    end

    Request.instant.future_flag_1.where('`date` <= ?',
                   (Time.now - Configurations[:cancel_future_no_fee_time].second)
    ).find_each do |request|
      request.canceled! true
    end

    self.delay(:run_at => 1.minute.from_now).do_interesting_things
  end

  def self.start_me_up
    new.do_interesting_things
  end
end
