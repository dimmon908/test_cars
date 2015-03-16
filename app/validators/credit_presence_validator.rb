#encoding: utf-8
class CreditPresenceValidator < ActiveModel::EachValidator

  # @param [Classes::PersonalAccount] record
  # @param [String] value
  def validate_each(record, attribute, value)
    return unless record.need_validate?
    if value.blank?
      record.errors[attribute] << 'Can\'t not be blank'
    end
  end
end