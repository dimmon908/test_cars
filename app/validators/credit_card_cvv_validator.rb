#encoding: utf-8
class CreditCardCvvValidator < ActiveModel::EachValidator

  # @param [Card] record
  # @param [String] value
  def validate_each(record, attribute, value)
    unless value.blank?
      result = false

      unless record.credit_card.blank?
        if record.credit_card.to_s[0] == '3'
          result = value =~ /^\d{4}$/
        else
          result = value =~ /^\d{3}$/
        end
      end

      record.errors[attribute] << I18n.t('model.errors.custom.credit_card_cvv_length') unless result
    end
  end
end