class AddLockToDrivers < ActiveRecord::Migration
  def change
    add_column :drivers, :lock, :boolean
  end
end
