class AddFutureFlagToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :future_flag, :boolean
  end
end
