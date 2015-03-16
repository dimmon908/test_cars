# encoding: UTF-8
class AddApproveToUsers < ActiveRecord::Migration
  def change
    add_column :users, :approve, :boolean
  end
end