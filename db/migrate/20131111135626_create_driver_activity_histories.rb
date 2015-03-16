# encoding: UTF-8
class CreateDriverActivityHistories < ActiveRecord::Migration
  def change
    create_table :driver_activity_histories, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.references :driver
      t.string :status, :limit => 30

      t.timestamps
    end
    add_index :driver_activity_histories, :driver_id
  end
end
