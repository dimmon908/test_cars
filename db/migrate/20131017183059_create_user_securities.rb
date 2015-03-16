#encoding: utf-8
class CreateUserSecurities < ActiveRecord::Migration
  def change
    create_table :user_securities, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.references :user
      t.string :reset_password_token
      t.timestamp :reset_password_token_at
      t.timestamp :remember_created_at
      t.integer :sign_in_count
      t.timestamp :current_sign_in
      t.timestamp :last_sign_in
      t.timestamp :expire_date
      t.timestamp :expire_token

      t.timestamps
    end
    add_index :user_securities, :user_id
  end
end
