#encoding: utf-8
class EmailsPull < ActiveRecord::Base
  scope :for_send, -> {where(:status => :new)}
  after_initialize :after_init
  before_save :before_save

  belongs_to :email
  belongs_to :user
  attr_accessible :failt_stamp, :params, :status, :success_stamp, :email, :user, :to_email, :user_id

  include Included::Deliver
  extend Excluded::Deliver

  def to
    to = to_email unless to_email.blank?
    to ||= user.email if user
    #to = Configurations[:admin_email]
  end

  def process
    Emailer.email(email.body_with_params(params), to, email.title, {content_type: 'text/html'}).deliver
    end

  protected
  def def_to
    self.to_email ||= user.email if user
  end
end
