class AddAltPhoneToDrivers < ActiveRecord::Migration
  def change
    add_column :drivers, :alt_phone, :string, :limit => 30
    add_column :drivers, :birthdate, :datetime
  end
end
