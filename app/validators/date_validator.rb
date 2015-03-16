#encoding: utf-8
class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value
      return unless value.is_a?String

       date = value.split '/'
       date = "20#{date[1]}-#{date[0]}-01"
      if Time.parse(date) < self.options[:in][0]
        record.errors[attribute] << I18n.t('model.errors.custom.date')
      end
    end
  end
end