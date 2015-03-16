class AddIndexToConfigs < ActiveRecord::Migration
  def change
    add_index :configurations, :internal_name
  end
end
