#encoding: utf-8
class RenameTypeInPromoCode < ActiveRecord::Migration
  def change
    rename_column :promo_codes, :type, :promo_type
  end
end
