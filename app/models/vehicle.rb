#encoding: utf-8
class Vehicle < ActiveRecord::Base
  attr_accessible :desc, :name, :photo, :passengers, :rate, :sort_order, :internal_name, :per_mile, :per_minute

  validates :rate, :vehicle_rate => true

  def self.only_future
    self::where(:internal_name => :sprinter)
  end

  def self.html_select
    Vehicle.all.collect do |p|
      [p.id, "#{image_tag(p.photo)}<br/><b>#{p.name}</b><br/><b>#{p.desc}</b>"]
    end
  end

  def self.admin_select
    Vehicle.select([:id, :name]).all.collect do |p|
      [p.name, p.id]
    end
  end

  def self.future_validation date
    date > (Time.now + Configurations[:future_request_sprinter_time].hour)
  end
end
