#encoding: utf-8
class AddBusinessInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :business_info_id, :integer
    add_index :users, :business_info_id
  end
end
