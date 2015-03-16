# encoding: UTF-8
class AddGenderToDrivers < ActiveRecord::Migration
  def change
    change_column :drivers, :gender, :string, :limit => 10
    change_column :drivers, :age_group, :string, :limit => 15
    change_column :drivers, :status, :string, :limit => 30
  end
end
