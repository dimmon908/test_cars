#encoding: utf-8
class CreateDriverRequestHistories < ActiveRecord::Migration
  def change
    create_table :driver_request_histories, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.references :request
      t.references :driver
      t.integer :status

      t.timestamps
    end
    add_index :driver_request_histories, :request_id
    add_index :driver_request_histories, :driver_id
  end
end
