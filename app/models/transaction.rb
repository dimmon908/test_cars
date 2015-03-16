#encoding: utf-8
class Transaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :request
  attr_accessible :base, :gratuity, :penalty, :summ, :tax, :total, :refund, :promo, :paid,
                  :paid_stamp, :refund_stamp,
                  :comment, :status,  :payment, :user, :partner_id, :request, :authorization_code,
                  :charged

  def full_price!
    self.full_price
    self.save
  end

  def full_price
    total = self.base.to_f + self.gratuity.to_f + self.penalty.to_f - self.promo.to_f
    total = 0 if total.to_i <= 0
    self.total = total
  end
end