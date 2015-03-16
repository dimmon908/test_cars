class AddBookedToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :booked, :datetime
  end
end
