#encoding: utf-8
class VehicleRateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value
      record.errors[attribute] << I18n.t('forms.config.value.incorrect') unless MessagePack.pack(value)
    end
  end
end