#encoding: utf-8
class DriverAvailableValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value == 'instant' && !Driver::available.any?
      record.errors[:no_driver] << I18n.t('activerecord.errors.models.request.attributes.status.driver_available')
    end
  end
end
