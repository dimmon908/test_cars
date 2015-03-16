class AddToPhoneToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :phone, :string, :limit => '50'
    add_index :requests, :phone
  end
end
