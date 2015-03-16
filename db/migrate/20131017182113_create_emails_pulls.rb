#encoding: utf-8
class CreateEmailsPulls < ActiveRecord::Migration
  def change
    create_table :emails_pulls, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.references :email
      t.references :user
      t.string :params
      t.integer :status
      t.timestamp :failt_stamp
      t.timestamp :success_stamp

      t.timestamps
    end
    add_index :emails_pulls, :email_id
    add_index :emails_pulls, :user_id
  end
end
