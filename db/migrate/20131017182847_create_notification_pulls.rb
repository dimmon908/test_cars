#encoding: utf-8
class CreateNotificationPulls < ActiveRecord::Migration
  def change
    create_table :notification_pulls, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.references :notification
      t.references :user
      t.string :params
      t.integer :status

      t.timestamps
    end
    add_index :notification_pulls, :notification_id
    add_index :notification_pulls, :user_id
  end
end
