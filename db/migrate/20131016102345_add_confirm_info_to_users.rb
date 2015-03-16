#encoding: utf-8
class AddConfirmInfoToUsers < ActiveRecord::Migration
=begin
  def change
    add_column :users, :confirmed_at, :integer
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmation_sent_at, :integer
    add_column :users, :unconfirmed_email, :string
  end
=end
end
