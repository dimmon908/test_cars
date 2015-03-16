#encoding: utf-8
class AddAdditionalInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_name, :string
    add_column :users, :username, :string
    add_column :users, :firstname, :string
    add_column :users, :phone, :string
    add_column :users, :zip_code, :string
    add_column :users, :status, :integer
    add_column :users, :can_receive_request, :boolean
    add_column :users, :credit_limit, :decimal
    add_column :users, :old_data, :string
  end
end
