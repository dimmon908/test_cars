class ChangeEtaToDrivers < ActiveRecord::Migration
  def change
    change_column :requests, :eta, :datetime
  end
end
