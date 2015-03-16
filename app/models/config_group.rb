#encoding: utf-8
class ConfigGroup < ActiveRecord::Base
  attr_accessible :internal_name, :public_name, :desc
end
