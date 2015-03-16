class DriverActivityHistory < ActiveRecord::Base
  belongs_to :driver
  attr_accessible :status, :driver_id, :driver
end
