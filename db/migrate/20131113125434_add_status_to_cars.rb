# encoding: UTF-8
class AddStatusToCars < ActiveRecord::Migration
  def change
    add_column :cars, :status, :string, :limit => 30
  end
end
