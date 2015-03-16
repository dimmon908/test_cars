#encoding: utf-8
class BusinessInfo < ActiveRecord::Base
  attr_accessible :approve_terms, :billing_address, :choose_payment,
                  :company_address, :credit_line, :duns_number, :employees, :requests_per_month, :year_in_business,
                  :email,  :name, :phone, :type_name, :city

  def can_credit?(amount)
    return true if credit_limit.to_i == 0
    (credit_limit.to_f - credit.to_f) > amount.to_f
  end
end
