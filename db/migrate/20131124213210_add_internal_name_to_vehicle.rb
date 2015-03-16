class AddInternalNameToVehicle < ActiveRecord::Migration
  def change
    add_column :vehicles, :internal_name, :string, :limit => 20
    add_index :vehicles, :internal_name
  end
end
