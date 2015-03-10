class AddRateToDrivers < ActiveRecord::Migration
  def change
    add_column :drivers, :rate, :float
  end
end
