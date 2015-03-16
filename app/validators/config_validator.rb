#encoding: utf-8
class ConfigValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank?
      record.errors[attribute] << I18n.t('forms.config.value.incorrect') unless MessagePack.pack(value)
    end
  end
end