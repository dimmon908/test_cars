#encoding: utf-8
class AddIndexesToUsersRoles < ActiveRecord::Migration
  def change
    add_index :roles, :internal_name, :unique => true
  end
end
