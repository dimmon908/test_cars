class AddIndexesToNotifications < ActiveRecord::Migration
  def change
    add_index :emails, :internal_name, :unique => true
    add_index :sms_messages, :internal_name, :unique => true
    add_index :notifications, :internal_name, :unique => true
  end
end
