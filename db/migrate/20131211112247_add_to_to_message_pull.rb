class AddToToMessagePull < ActiveRecord::Migration
  def change
    add_column :sms_messages_pulls, :to, :string, :limit => 49
  end
end
