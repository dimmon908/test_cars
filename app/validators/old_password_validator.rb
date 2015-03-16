#encoding: utf-8
class OldPasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value && record.password
      record.errors[attribute] << I18n.t('model.errors.custom.old_password') if record.valid_password? value
    end
  end
end