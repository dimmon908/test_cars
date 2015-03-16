class AddPaymentToTransaction < ActiveRecord::Migration
  def change
    rename_column :transactions, :type, :payment
    change_column :transactions, :payment, :string, :limit => 30
    add_index :transactions, :payment, :length => 30
  end
end
