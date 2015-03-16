#encoding: utf-8
class CreateFares < ActiveRecord::Migration
  def change
    create_table :fares, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.decimal :fare, :precision => 15, :scale => 10
      t.integer :type
      t.boolean :enabled
      t.datetime :from
      t.timestamp :to

      t.timestamps
    end
  end
end
