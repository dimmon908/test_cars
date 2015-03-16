# encoding: UTF-8
class AddPidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :partner_id, :integer
    add_index :users, :partner_id
  end
end
