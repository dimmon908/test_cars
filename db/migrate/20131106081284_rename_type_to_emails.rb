# encoding: UTF-8
class RenameTypeToEmails < ActiveRecord::Migration
  def change
    rename_column :emails, :type, :body_type
  end
end
