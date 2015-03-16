# encoding: UTF-8
class AddDescToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :desc, :text
    add_column :notifications, :desc, :text
    add_column :sms_messages, :desc, :text
  end
end
