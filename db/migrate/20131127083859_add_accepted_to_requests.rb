class AddAcceptedToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :accepted, :datetime
    add_column :requests, :cancelled, :datetime
  end
end
