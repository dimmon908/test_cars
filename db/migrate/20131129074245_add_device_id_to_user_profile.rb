class AddDeviceIdToUserProfile < ActiveRecord::Migration
  def change
    add_column :user_profile, :device_id, :string
    add_index :user_profile, :device_id
  end
end