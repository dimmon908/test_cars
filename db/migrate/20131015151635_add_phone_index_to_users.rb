#encoding: utf-8
class AddPhoneIndexToUsers < ActiveRecord::Migration
  def change
    add_index :users, :phone,  :unique => true
  end
end
