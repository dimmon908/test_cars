#encoding: utf-8
class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :name
      t.references :country
      t.string :code, :limit => 5

      t.timestamps
    end
    add_index :cities, :country_id
  end
end
