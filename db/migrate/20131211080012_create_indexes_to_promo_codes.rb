class CreateIndexesToPromoCodes < ActiveRecord::Migration
  def change
    remove_index :promo_codes, :name => :index_promo_codes_on_code

    add_index :promo_codes, :code, :unique => true
    add_index :promo_codes, :name, :unique => true
  end
end
