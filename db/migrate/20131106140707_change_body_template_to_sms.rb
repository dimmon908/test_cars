# encoding: UTF-8
class ChangeBodyTemplateToSms < ActiveRecord::Migration
  def change
    rename_column :sms_messages, :body, :body_template
    rename_column :notifications, :body, :body_template
  end
end
