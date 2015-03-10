class AddOwnerInfoToCreditCardInfo < ActiveRecord::Migration
  def change
    add_column :credit_card_info, :owner, :string, :limit => 100
  end
end
