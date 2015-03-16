class AddAuthorizationCodeToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :authorization_code, :string, :limit => 30
  end
end
