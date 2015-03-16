class AddShownToUsers < ActiveRecord::Migration
  def change
    add_column :users, :show, :boolean, :default => true
  end
end
