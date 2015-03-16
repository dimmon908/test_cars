class RemoveFieldsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :credit_limit
    add_column :user_profile, :country, :string, :limit => 50
    remove_column :users, :country
  end
end
