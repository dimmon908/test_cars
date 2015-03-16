class AddInfoToPullTables < ActiveRecord::Migration
  def change
    add_column :emails_pulls, :to_email, :string, :limit => 100
    add_column :sms_messages_pulls, :to_phone, :string, :limit => 50
  end
end
