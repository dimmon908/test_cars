#encoding: utf-8
class CreditCardOnlineServerValidator < ActiveModel::EachValidator

  # @param [Card] record
  # @param [String] value
  def validate_each(record, attribute, value)
    return unless record.hash?
    return if value.blank?

    if record.user
      first_name = record.user.first_name
      last_name = record.user.last_name
    else
      first_name = record.first_name
      last_name = record.last_name
    end

    number = record.card_number
    cvv = record.cvv
    postal = record.postal_code

    date = record.expiration_date_month.to_s
    if record.expiration_date_year.to_s.length == 2
      date += record.expiration_date_year.to_s
    else
      date += record.expiration_date_year.to_s[-2, 2]
    end

    card = ::AuthorizeNet::CreditCard.new(number, date, :card_code =>  cvv)
    bill = Payment::AuthorizeNet.new

    response = bill.check card, first_name, last_name, postal

    if response.success?
      bill.check_void response.transaction_id
    else
      record.errors[attribute] << response.response_reason_text and return if response.response_reason_code.to_i == 2 || response.response_reason_code.to_i == 65
      record.errors[attribute] << I18n.t('errors.messages.declined_cc')
    end

  end
end