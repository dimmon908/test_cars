class RemoveEnabledToUsers < ActiveRecord::Migration
  def change
    remove_column :users, :enabled
  end
end
