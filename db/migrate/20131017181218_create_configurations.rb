#encoding: utf-8
class CreateConfigurations < ActiveRecord::Migration
  def change
    create_table :configurations, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :internal_name
      t.string :key, :limit => 50
      t.string :value
      t.integer :area
      t.integer :scope

      t.timestamps
    end
  end
end
