class AddExperianceToDrivers < ActiveRecord::Migration
  def change
    add_column :drivers, :exp, :float
  end
end
