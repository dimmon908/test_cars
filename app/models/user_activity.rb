#encoding: utf-8
class UserActivity < ActiveRecord::Base
  belongs_to :user
  belongs_to :action_types
  attr_accessible :params, :status
end
