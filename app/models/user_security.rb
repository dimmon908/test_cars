#encoding: utf-8
class UserSecurity < ActiveRecord::Base
  belongs_to :user
  attr_accessible :current_sign_in, :expire_date, :expire_token, :last_sign_in, :remember_created_at, :reset_password_token, :reset_password_token_at, :sign_in_count
end
