class AddVehicleToCars < ActiveRecord::Migration
  def change
    add_column :cars, :vehicles_id, :integer
    add_index :cars, :vehicles_id
  end
end
