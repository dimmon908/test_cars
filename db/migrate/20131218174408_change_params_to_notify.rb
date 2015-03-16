class ChangeParamsToNotify < ActiveRecord::Migration
  def change
    change_column :sms_messages_pulls, :params, :text
    change_column :emails_pulls, :params, :text
    change_column :notification_pulls, :params, :text
  end
end
