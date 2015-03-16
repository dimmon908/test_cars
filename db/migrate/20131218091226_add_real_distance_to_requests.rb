class AddRealDistanceToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :real_distance, :float
  end
end
