class AddChargedToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :charged, :decimal, :precision => 12, :scale => 2
  end
end
