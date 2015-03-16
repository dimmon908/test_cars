class ChangeExtIdToTransactions < ActiveRecord::Migration
  def change
    change_column :transactions, :ext_id, :integer, :limit => 8
  end
end
