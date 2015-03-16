#encoding: utf-8
class PromoCodeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank?
      #promo = PromoCode::find_by_code value rescue nil
      promo = PromoCode::find_by_name value rescue nil
      promo = PromoCode::find_by_code value unless promo

      record.errors[attribute] << I18n.t('model.errors.custom.promo_code') and return unless promo
      record.errors[attribute] << I18n.t('model.errors.custom.promo_code') and return if promo.from && promo.from > Time.now
      record.errors[attribute] << I18n.t('model.errors.custom.promo_code') and return if promo.until && promo.until < Time.now
      record.errors[attribute] << I18n.t('model.errors.custom.promo_code') and return unless promo.enabled


      record.errors[attribute] << I18n.t('model.errors.custom.promo_code') and return if promo.single? && PromoCodeHistory::where(:promo_code_id => promo.id).any?
      record.errors[attribute] << I18n.t('model.errors.custom.promo_code') and return if promo.once_per_user? && PromoCodeHistory::where(:promo_code_id => promo.id, :user_id => record.user_id).any?

    end
  end
end