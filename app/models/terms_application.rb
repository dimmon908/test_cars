class TermsApplication < ActiveRecord::Base
  belongs_to :user
  belongs_to :admin, :class_name => 'User'

  attr_accessible :approved, :received, :user, :admin_id, :admin, :user_id, :first_name, :last_name, :email, :phone_code, :phone, :job_title
end
