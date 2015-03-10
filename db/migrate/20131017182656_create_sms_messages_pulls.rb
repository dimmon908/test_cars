#encoding: utf-8
class CreateSmsMessagesPulls < ActiveRecord::Migration
  def change
    create_table :sms_messages_pulls, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.references :sms_message
      t.references :user
      t.string :params
      t.integer :status
      t.timestamp :fail_stamp
      t.timestamp :success_stamp

      t.timestamps
    end
    add_index :sms_messages_pulls, :sms_message_id
    add_index :sms_messages_pulls, :user_id
  end
end
