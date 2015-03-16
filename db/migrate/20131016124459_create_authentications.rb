#encoding: utf-8
class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.references :user
      t.string :provider
      t.string :uid
      t.string :token
      t.string :token_secret

      t.timestamps
    end
    add_index :authentications, :user_id
  end
end
