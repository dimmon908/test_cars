# encoding: UTF-8
class RenameTokenToUsers < ActiveRecord::Migration
  def change
    rename_column :users, :token, :api_token
  end
end
