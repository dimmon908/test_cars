#encoding: utf-8
class AddIndexToCars < ActiveRecord::Migration
  def change
    add_index :cars, :place_number, :unique => true
  end
end
