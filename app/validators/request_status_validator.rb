#encoding: utf-8
class RequestStatusValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value && record.user
      return unless record.user.role?(:personal)
      if value == 'instant'
        record.errors[attribute] <<
            I18n.t('model.errors.custom.exist_instant_request') if Request::where('`user_id` = ? AND `status` IN (?) AND id != ?',
                                                                                  record.user.id,
                                                                                  [:started, :accept, :waiting, :instant],
                                                                                  record.id.to_i
                                                                                ).any?
      elsif value == 'future'
       record.errors[attribute] <<
           I18n.t('model.errors.custom.exist_future_request') if Request::where('`user_id` = ? AND `status` = ? AND id != ? AND  date > ? AND date < ?',
                                                                                 record.user.id,
                                                                                 :future,
                                                                                 record.id.to_i,
                                                                                 record.date - Configurations[:instant_request_time].minutes,
                                                                                 record.date + Configurations[:instant_request_time].minutes
                                                                                ).any?
      end
    end
  end
end