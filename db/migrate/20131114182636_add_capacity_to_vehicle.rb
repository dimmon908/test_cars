class AddCapacityToVehicle < ActiveRecord::Migration
  def change
    add_column :vehicles, :passengers, :integer
  end
end
