class AddUserToFares < ActiveRecord::Migration
  def change
    add_column :fares, :user_id, :integer
    add_index :fares, :user_id

    rename_column :fares, :type, :fare_type
    change_column :fares, :fare_type, :string, :limit => 30

    add_index :fares, :enabled
    add_index :fares, [:enabled, :fare_type]
  end
end
