class AddRefundStampToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :refund_stamp, :datetime
  end
end
