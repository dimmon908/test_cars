#encoding: utf-8
class OldEmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value && record.email
      record.errors[attribute] << I18n.t('model.errors.custom.old_email') if record.email.to_s != value.to_s
    end
  end
end