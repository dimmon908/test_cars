#encoding: utf-8
class AddDistanceToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :distance, :float
  end
end
