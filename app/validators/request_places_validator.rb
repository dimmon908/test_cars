#encoding: utf-8
class RequestPlacesValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    elem = value['0'].to_s if value.is_a?Hash
    elem = value[0].to_s if value.is_a?Array
    return if elem == ''

    record.errors[attribute] << I18n.t('activerecord.errors.models.request.attributes.to.request_places') if elem == record.from.to_s
  end
end