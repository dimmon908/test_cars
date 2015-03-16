class ChangeValueToPayment < ActiveRecord::Migration
  def change
    change_column :payments, :value, :decimal, :precision => 12, :scale => 2
  end
end
