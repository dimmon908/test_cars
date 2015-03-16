class AddCarToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :car_id, :integer
    add_index :requests, :car_id
  end
end
