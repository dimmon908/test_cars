# encoding: UTF-8
class AddSortOrderToVehicle < ActiveRecord::Migration
  def change
    add_column :vehicles, :sort_order, :integer
  end
end
