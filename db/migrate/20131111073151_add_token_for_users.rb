# encoding: UTF-8
class AddTokenForUsers < ActiveRecord::Migration
  def change
    add_column :users, :token, :string, :limit => 50
    add_column :users, :token_expire, :datetime
  end
end
