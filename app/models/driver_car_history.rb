#encoding: utf-8
class DriverCarHistory < ActiveRecord::Base
  belongs_to :driver
  belongs_to :car
  attr_accessible :comment, :status, :driver, :car
end
