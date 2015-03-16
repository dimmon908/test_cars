#encoding: utf-8
class ChangeRateInRequests < ActiveRecord::Migration
  def change
    change_column :requests, :rate, :decimal
  end
end
