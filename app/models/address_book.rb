#encoding: utf-8
class AddressBook < ActiveRecord::Base
  belongs_to :user
  attr_accessible :address, :public_name, :show, :sort_order, :user_id

  after_initialize :after_init
  before_save :before_save

  validates_presence_of :address

  private
  def after_init
    self.public_name = self.address if self.address && (self.public_name.nil? || self.public_name == '')
  end

  def before_save
    self.public_name = '' if self.public_name == self.address
  end
end
