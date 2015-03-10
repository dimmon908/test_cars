# encoding: UTF-8
class ChangeStatusToEmailsPull < ActiveRecord::Migration
  def change
    change_column :emails_pulls, :status, :string, :limit => 15, :default => :new
    change_column :sms_messages_pulls, :status, :string, :limit => 15, :default => :new
    change_column :notification_pulls, :status, :string, :limit => 15, :default => :new
  end
end
