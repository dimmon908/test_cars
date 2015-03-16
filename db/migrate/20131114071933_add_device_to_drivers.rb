class AddDeviceToDrivers < ActiveRecord::Migration
  def change
    add_column :drivers, :device_id, :string
    add_column :drivers, :online, :boolean
    add_index :drivers, :online
  end
end
