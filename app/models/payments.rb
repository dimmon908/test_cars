class Payments < ActiveRecord::Base
  PAID_VIA = {
      :cash => 'Cashiers Check',
      :money => 'Money Order',
      :bank => 'Bank Transfer'
  }

  before_create :before_create
  after_create :after_create

  belongs_to :user
  belongs_to :admin, :class_name => 'User'

  attr_accessible :date, :paid_via, :value, :user_id, :admin_id

  validates :value,
            :presence => true,
            :numericality => true,
            :format => { :with => /^\d{1,10}(\.\d{0,2})?$/ }

  validates :date, :presence => true

  protected
  def before_create
  end

  def after_create
    client = User::user_object_by_role self.user.role, self.user_id
    client.credit += self.value
    client.save :validate => false
  end
end
