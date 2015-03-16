#encoding: utf-8
class CreatePromoCodes < ActiveRecord::Migration
  def change
    create_table :promo_codes, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.datetime :from
      t.datetime :until
      t.string :name
      t.integer :order_over
      t.integer :type
      t.integer :value
      t.integer :per_user
      t.integer :uses_count
      t.integer :max_uses_number
      t.boolean :enabled
      t.integer :single

      t.timestamps
    end
  end
end
