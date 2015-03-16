class ClientActivityHistory < ActiveRecord::Base
  belongs_to :user
  attr_accessible :action, :date, :device_id, :device_system, :request, :response, :user_type, :user_id, :user
end
