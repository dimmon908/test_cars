class AddPromoToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :promo, :decimal, :precision => 12, :scale => 2
  end
end
