#encoding: utf-8
class CreateDriverCarHistories < ActiveRecord::Migration
  def change
    create_table :driver_car_histories, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.references :driver
      t.references :car
      t.integer :status
      t.string :comment

      t.timestamps
    end
    add_index :driver_car_histories, :driver_id
    add_index :driver_car_histories, :car_id
  end
end
