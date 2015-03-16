class AddWaitRatesToVehicle < ActiveRecord::Migration
  def change
    add_column :vehicles, :per_wait_minute, :float, :default => 0.35
  end
end
