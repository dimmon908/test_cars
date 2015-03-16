class AddUserIdToCreditCard < ActiveRecord::Migration
  def change
    add_column :credit_card_info, :user_id, :integer
    add_index :credit_card_info, :user_id
  end
end
