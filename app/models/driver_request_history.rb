#encoding: utf-8
class DriverRequestHistory < ActiveRecord::Base
  scope :breaks, ->(trip_id, driver_id) {where(:request_id => trip_id, :driver_id => driver_id, :status => :decline)}
  scope :accepts, ->(id) {where(:request_id => id, :status => :accepted)}
  scope :started, ->(trip_id) {where(:request_id => trip_id, :status => ::Trip::Status::STARTED)}
  scope :waiting, ->(trip_id) {where(:request_id => trip_id, :status => ::Trip::Status::WAITING)}
  belongs_to :request
  belongs_to :driver
  attr_accessible :status, :driver, :request

  #@param [Request] request
  def self.add(request)
    history = self.new
    history.driver = request.driver
    history.request = request
    history.status = request.status
    history.save
  end
end
