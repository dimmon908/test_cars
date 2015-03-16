#encoding: utf-8
class CreateSmsMessages < ActiveRecord::Migration
  def change
    create_table :sms_messages, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :internal_name
      t.string :title
      t.text :body
      t.integer :type
      t.integer :sort_order

      t.timestamps
    end
  end
end
