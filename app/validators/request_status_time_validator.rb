#encoding: utf-8
class RequestStatusTimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless Trip::Status::future? record

    if value.to_s != ''
      min = Configurations[:instant_request_time]

      date = record.datetime_date value rescue nil

      record.errors[attribute] << I18n.t('model.errors.custom.invalid_date_format') and return unless date
      Rails.logger.error("::::: RequestStatusTimeValidator:: this is the future date placement of the request #{date.strftime('%Y-%m-%dT%H:%M:%S%:z')}")
      Rails.logger.error("::::: RequestStatusTimeValidator:: this is the current time #{DateTime.now.strftime('%Y-%m-%dT%H:%M:%S%:z')}")

      record.errors[attribute] << I18n.t('model.errors.custom.future_request_min_period', :min => min) if date < (DateTime.now + min.minute)
    end
  end
end