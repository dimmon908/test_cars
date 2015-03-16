#encoding: utf-8
class CreditCardBusinessValidator < ActiveModel::EachValidator

  # @param [Card] record
  # @param [String] value
  def validate_each(record, attribute, value)
    return unless record.validate_card?
    if value.blank?
      record.errors[:expiration_date_month] << 'Choose Month'
      record.errors[:expiration_date_year] <<  'Choose Year'
    end
  end
end