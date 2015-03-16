class RenameVehiclesIdToCars < ActiveRecord::Migration
  def change
    rename_column :cars, :vehicles_id, :vehicle_id
  end
end
