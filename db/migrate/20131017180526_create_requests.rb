#encoding: utf-8
class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.references :user
      t.references :driver
      t.integer :type
      t.integer :status
      t.string :from
      t.string :to
      t.datetime :date
      t.decimal :rate, :precision => 15, :scale => 10
      t.integer :passengers
      t.float :luggage
      t.string :comment
      t.string :reserve_number
      t.references :promo_code
      t.string :params
      t.float :time
      t.string :payment_options, :limit => 100

      t.timestamps
    end
    add_index :requests, :user_id
    add_index :requests, :driver_id
    add_index :requests, :promo_code_id
  end
end
