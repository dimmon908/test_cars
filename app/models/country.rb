#encoding: utf-8
class Country < ActiveRecord::Base
  attr_accessible :c, :code, :name
end
