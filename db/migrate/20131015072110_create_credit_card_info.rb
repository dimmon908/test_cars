#encoding: utf-8
class CreateCreditCardInfo < ActiveRecord::Migration
  def up
    create_table(:credit_card_info, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.integer :card_number,       :null => false, :default => ''
      t.datetime :card_expire,      :null => false
      t.string :cvv,                :null => false, :default => ''
      t.timestamp :checked,         :null => false

      t.timestamps
    end
  end
end
