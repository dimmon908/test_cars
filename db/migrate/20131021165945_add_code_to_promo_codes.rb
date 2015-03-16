#encoding: utf-8
class AddCodeToPromoCodes < ActiveRecord::Migration
  def change
    add_column :promo_codes, :code, :string, :limit => 30
    add_index :promo_codes, :code
  end
end
