#encoding: utf-8
# == Schema Information
#
# Table name: cars
#
#  id                 :integer          not null, primary key
#  place_number       :string(100)
#  manufacturer       :string(50)
#  model_name         :string(50)
#  model_year         :integer
#  color              :string(50)
#  passenger_capacity :integer
#  fuel_type          :string(30)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  status             :string(30)
#  vehicle_id         :integer
#

class Car < ActiveRecord::Base
  scope :available, -> { Driver.online.any? ? where('id NOT IN (?)', Driver.online.all.collect{|c| c.car_id }) : where('') }
  scope :booked_cars, -> { Driver.online.any? ? where('id IN (?)', Driver.online.all.collect{|c| c.car_id }) : where('') }
  include CarExt::ExportCsv
  belongs_to :vehicle

  after_initialize :after_init
  after_save :after_save

  attr_accessible :color, :fuel_type, :manufacturer, :model_name, :model_year, :passenger_capacity, :place_number, :photo, :vehicle_id
  attr_accessor :photo, :car_photoses

  validates_presence_of   :place_number
  validates_uniqueness_of :place_number, :allow_blank => true

  validates_presence_of   :manufacturer
  validates_presence_of   :model_name
  validates_presence_of   :model_year
  validates_presence_of   :color
  validates_presence_of   :passenger_capacity
  validates_presence_of   :fuel_type

  def to_js
    {
        :plate_id => id,
        :color => color,
        :name => model_name,
        :plate_number => place_number,
        :vehicle_id => vehicle_id
    }
  end

  protected
  def after_init
    if self.car_photoses.nil? && self.id
      self.car_photoses = CarPhotos.where(car_id: self.id).all
    end
    self.car_photoses ||= []

    begin
      if self.vehicle.blank? && self.vehicle_id.to_i > 0
        self.vehicle = Vehicle::find self.vehicle_id
      end
    rescue Exception => e
    end

    self.vehicle ||= Vehicle.first
  end

  def after_save
    if self.photo && self.car_photoses.size < Configurations[:max_car_photos]
      CarPhotos.create([:car_id => self.id, :photo => self.photo])
    end
  end
end
