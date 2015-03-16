# encoding: UTF-8
class AddBodyTypeToSmsMessage < ActiveRecord::Migration
  def change
    add_column :sms_messages, :body_type, :string, :limit => 15
    remove_column :sms_messages, :type

    add_column :notifications, :body_type, :string, :limit => 15
    remove_column :notifications, :type
  end
end
