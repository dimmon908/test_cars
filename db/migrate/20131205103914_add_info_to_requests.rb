class AddInfoToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :partner_id, :integer
    add_column :requests, :cancelled_user_id, :integer

    add_index :requests, :partner_id
    add_index :requests, :cancelled_user_id
    add_index :requests, :status
  end
end
