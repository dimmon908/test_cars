class AddExtIfToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :ext_id, :integer
    add_index :transactions, :ext_id
  end
end
