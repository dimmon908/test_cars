class DelayPayment
  def pay(id)
    trip = Request.find id rescue nil
    Log << {:type => :delay_pay, :id => id, :trip => trip}.to_s
    trip.apply_pay if trip
  end

  def self.add_log(data)
    Log << data.to_s
  end

  def self.delay_pay(id)
    add_log({:type => :delay_pay, :id => id, :time => Configurations[:finish_transaction_timeout].minute.from_now})
    new.delay(:run_at => Configurations[:finish_transaction_timeout].minute.from_now).pay id
  end
end