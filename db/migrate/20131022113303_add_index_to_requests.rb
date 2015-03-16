#encoding: utf-8
class AddIndexToRequests < ActiveRecord::Migration
  def change
    rename_column :requests, :type, :vehicle_id
    add_index :requests, :vehicle_id
  end
end
