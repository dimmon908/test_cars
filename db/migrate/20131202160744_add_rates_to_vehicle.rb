class AddRatesToVehicle < ActiveRecord::Migration
  def change
    add_column :vehicles, :per_mile, :float, :default => 30
    add_column :vehicles, :per_minute, :float, :default => 2
  end
end
