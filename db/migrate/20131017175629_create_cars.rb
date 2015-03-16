#encoding: utf-8
class CreateCars < ActiveRecord::Migration
  def change
    create_table :cars, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :place_number
      t.string :manufacturer, :limit => 50
      t.string :model_name, :limit => 50
      t.integer :model_year
      t.string :color, :limit => 50
      t.integer :passenger_capacity
      t.string :fuel_type, :limit => 30

      t.timestamps
    end
  end
end
