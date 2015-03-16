#encoding: utf-8
class AddIndexesToUsers < ActiveRecord::Migration
  def change
    add_index :users, :username,                :unique => true
  end
end
