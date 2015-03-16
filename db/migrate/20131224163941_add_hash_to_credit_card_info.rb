class AddHashToCreditCardInfo < ActiveRecord::Migration
  def change
    add_column :credit_card_info, :card_hash, :string, :limit => 50
  end
end
