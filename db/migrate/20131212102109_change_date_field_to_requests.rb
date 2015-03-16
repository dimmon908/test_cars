class ChangeDateFieldToRequests < ActiveRecord::Migration
  def change
    change_column :requests, :date, :datetime
  end
end
