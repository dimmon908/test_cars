#encoding: utf-8
class CreateVehicles < ActiveRecord::Migration
  def change
    create_table :vehicles, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :photo
      t.string :name
      t.string :desc

      t.timestamps
    end
  end
end
