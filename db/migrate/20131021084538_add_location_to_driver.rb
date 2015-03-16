#encoding: utf-8
class AddLocationToDriver < ActiveRecord::Migration
  def change
    add_column :drivers, :latitude,  :float
    add_column :drivers, :longitude, :float
    add_column :drivers, :gmaps, :boolean
  end
end
