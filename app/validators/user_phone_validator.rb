#encoding: utf-8
class UserPhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value
      if record.user_id
        user = User::where('phone = ? and user_id != ?', value, record.user_id).any? rescue nil
        record.errors[attribute] << I18n.t('model.errors.custom.user_phone') if user
      else
        user = User::where('phone = ?', value).any? rescue nil
        record.errors[attribute] << I18n.t('model.errors.custom.user_phone') if user
      end
    end
  end
end