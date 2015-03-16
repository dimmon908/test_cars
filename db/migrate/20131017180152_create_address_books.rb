#encoding: utf-8
class CreateAddressBooks < ActiveRecord::Migration
  def change
    create_table :address_books, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.references :user
      t.string :public_name
      t.string :address
      t.integer :sort_order
      t.boolean :show

      t.timestamps
    end
    add_index :address_books, :user_id
  end
end
