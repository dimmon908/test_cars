class RequestCancelReason < ActiveRecord::Base
  attr_accessible :comment, :reason

  validates_presence_of   :comment

  validates_presence_of   :reason
  validates_uniqueness_of :reason, :allow_blank => true
end
