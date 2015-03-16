#encoding: utf-8
class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :name
      t.string :c
      t.string :code, :limit => 5

      t.timestamps
    end
  end
end
