#encoding: utf-8
class UserEmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value && !record.user_id
      user = User::where(email: value).any? rescue nil
      record.errors[attribute] << I18n.t('model.errors.custom.user_email') if user
    end
  end
end