class ChangeMaxUsesNumberToPromoCodes < ActiveRecord::Migration
  def change
    change_column :promo_codes, :max_uses_number, :string, :limit => 30
  end
end
