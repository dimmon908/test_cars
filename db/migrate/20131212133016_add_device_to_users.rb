class AddDeviceToUsers < ActiveRecord::Migration
  def change
    add_column :user_profile, :device, :string, :limit => 15
    add_column :drivers, :device, :string, :limit => 15
  end
end
