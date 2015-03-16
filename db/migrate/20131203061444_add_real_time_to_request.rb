class AddRealTimeToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :real_time, :float
  end
end
