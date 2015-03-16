#encoding: utf-8
class PromoNameUniqueValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank?
      if record.id
        record.errors[attribute] << I18n.t('activerecord.errors.models.promo_code.attributes.code.promo_name_unique') and return if PromoCode::where('id != ? and name = ?', record.id, value).any?
      else
        record.errors[attribute] << I18n.t('activerecord.errors.models.promo_code.attributes.code.promo_name_unique') and return if PromoCode::where(:name => value).any?
      end
    end
  end
end