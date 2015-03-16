class AddBaseRateToVechicke < ActiveRecord::Migration
  def change
    add_column :vehicles, :rate, :float
  end
end
