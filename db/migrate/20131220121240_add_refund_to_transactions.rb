class AddRefundToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :refund, :decimal, :precision => 12, :scale => 2
  end
end
