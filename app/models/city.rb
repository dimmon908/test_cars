#encoding: utf-8
class City < ActiveRecord::Base
  belongs_to :country
  belongs_to :business_info
  attr_accessible :code, :name

  def self.list
    City.select([:id, :name]).all.collect{|p| [p.name]}
  end
end
