#encoding: utf-8
class ActivateData < ActiveRecord::Base
  scope :for_user, ->(id) {where(:user_id => id)}
  belongs_to :user
  attr_accessible :token, :code, :expire, :user_id, :activate_type, :user

  before_create :before_create


  def email?
    self.activate_type.to_sym == :email
  end

  def sms?
    self.activate_type.to_sym == :sms
  end


  protected
  def before_create
    unless self.token
      self.token = loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless self.class.exists?(token: random_token)
      end
    end

    self.code ||= rand(1000000..9999999)
  end
end