class AddOrdersTypeToPromoCodes < ActiveRecord::Migration
  def change
    add_column :promo_codes, :orders_type, :string, :limit => 15
    add_column :promo_codes, :over_value, :float
    change_column :promo_codes, :max_uses_number, :string, :limit => 20
  end
end
