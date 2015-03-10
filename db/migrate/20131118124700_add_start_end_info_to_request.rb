class AddStartEndInfoToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :start, :datetime
    add_column :requests, :end, :datetime
  end
end
