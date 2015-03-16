# encoding: UTF-8
class ChangeStatusInDriverCarHistory < ActiveRecord::Migration
  def change
    change_column :driver_car_histories, :status, :string, :limit => 30
  end
end
