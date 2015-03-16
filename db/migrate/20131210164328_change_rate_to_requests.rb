class ChangeRateToRequests < ActiveRecord::Migration
  def change
    change_column :requests, :rate, :decimal, :precision => 12, :scale => 2
  end
end
