# encoding: UTF-8
class AddTypeToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :type, :string, :limit => 15
  end
end
