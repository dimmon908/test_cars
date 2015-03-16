class AddIndexToDrivers < ActiveRecord::Migration
  def change
    add_index :drivers, [:online, :status]
  end
end