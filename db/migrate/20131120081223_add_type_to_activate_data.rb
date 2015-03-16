class AddTypeToActivateData < ActiveRecord::Migration
  def change
    add_column :activate_data, :activate_type, :string, :limit => 10
    add_index :activate_data, :token
  end
end
