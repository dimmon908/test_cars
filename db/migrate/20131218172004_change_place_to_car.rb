class ChangePlaceToCar < ActiveRecord::Migration
  def change
    change_column :cars, :place_number, :string, :limit => 100
  end
end
