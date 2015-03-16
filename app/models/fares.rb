#encoding: utf-8
class Fares < ActiveRecord::Base
  belongs_to :user
  attr_accessible :enabled, :fare, :fare, :from, :to, :fare_type, :user_id

  # @return [Array<Fares>]
  def self.by_type(type)
    Fares::where(:enabled => 1, :fare_type => type)
  end

  def self.change_fare(type, value, user_id, old_value)
    if self.by_type(type).any?
      fare = self.by_type(type).first
      fare.enabled = 0
      fare.user_id = user_id
      fare.to = Time.now
      fare.save
    else
      Fares.create({
         :fare => old_value,
         :fare_type => type,
         :user_id => user_id,
         :from => '1970-01-01 00:00:00',
         :to => Time.now,
         :enabled => 0
      })
    end

    Fares.create({
      :fare => value,
      :fare_type => type,
      :user_id => user_id,
      :from => Time.now,
      :enabled => 1
    })
  end

  def self.calculate(distance, time, base, vehicle, wait_time = 0)
    miles = HelperTools::meters_to_miles distance
    rate_a = base
    rate_a += Fares::by_miles miles, vehicle
    #rate_a += Fares::by_wait_time wait_time, vehicle if wait_time > 0

    rate_b = rate_a

    rate_a += Fares::by_time time, vehicle if time #&& (miles/HelperTools::to_hours(time)) < Configurations[:min_miles_for_minute].to_f

    rate = (rate_a > rate_b)? rate_a : rate_b

    minimum = Configurations[:minimum_fare].to_f
    rate = minimum if rate < minimum
    rate
  end

  # some trips have fixed prices regardless of time and distance
  # for example all trips from san francisco address to SOF has a fixed price
  # see ICWEB-24 for more details
  def self.get_special_rate(from, _to)
    if _to.kind_of?(Array)
      to = _to.first
    else
      to = _to
    end

    special_rate = nil
    if from =~ /(.*)San Francisco(.*)/
      if to =~ /(.*)San Francisco ((International )*)Airport(.*)/
        special_rate = 65
      elsif to =~ /(.*)San Jose ((International )*)Airport(.*)/
        special_rate = 130
      elsif to =~ /(.*)Oakland ((International )*)Airport(.*)/
        special_rate = 90
      end
    end
    special_rate
  end

  def self.finish_recheck(rate, estimated)
    return rate unless rate && estimated
    return rate if estimated.to_f > rate.to_f

    max_rate = estimated.to_f * (1 + Configurations[:max_rate_over_estimated].to_f/100.00)
    max_rate if rate.to_f > max_rate.to_f
  end

  def self.by_time(time, vehicle)
    vehicle.per_minute * HelperTools::to_minutes(time)
  end

  def self.by_wait_time(time, vehicle)
    vehicle.per_wait_minute * HelperTools::to_minutes(time)
  end

  def self.by_meters(distance, vehicle)
    Fares::by_miles HelperTools::meters_to_miles(distance), vehicle
  end
  def self.by_miles(miles, vehicle)
    vehicle.per_mile * miles
  end
end
