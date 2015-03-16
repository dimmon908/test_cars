#encoding: utf-8
class CreditCardLengthValidator < ActiveModel::EachValidator
  CARD_TYPES = [
    { name: 'amex', pattern: /^3[47]/, valid_length: 15 },
    { name: 'diners_club_carte_blanche', pattern: /^30[0-5]/, valid_length: 14 },
    { name: 'diners_club_international', pattern: /^36/, valid_length: 14 },
    { name: 'jcb', pattern: /^35(2[89]|[3-8][0-9])/, valid_length: 16 },
    { name: 'laser', pattern: /^(6304|670[69]|6771)/, valid_length: 16..19 },
    { name: 'visa_electron', pattern: /^(4026|417500|4508|4844|491(3|7))/, valid_length: 16 },
    { name: 'visa', pattern: /^4/, valid_length: 16 },
    { name: 'mastercard', pattern: /^5[1-5]/, valid_length:16 },
    { name: 'maestro', pattern: /^(5018|5020|5038|6304|6759|676[1-3])/, valid_length: 12..19 },
    { name: 'discover', pattern: /^(6011|622(12[6-9]|1[3-9][0-9]|[2-8][0-9]{2}|9[0-1][0-9]|92[0-5]|64[4-9])|65)/, valid_length: 16 }
  ]

  def validate_each(record, attribute, value)
    unless value.blank?
      result = false
      CARD_TYPES.each { |type|
        if value =~ type[:pattern]
          result = true if type[:valid_length].is_a?(Range) && type[:valid_length].include?(value.to_s.length)
          result = true if type[:valid_length].is_a?(Fixnum) && type[:valid_length] == value.to_s.length
        end
      }
      record.errors[attribute] << I18n.t('model.errors.custom.credit_card') unless result
    end
  end
end