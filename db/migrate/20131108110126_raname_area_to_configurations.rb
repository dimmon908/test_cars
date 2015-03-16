# encoding: UTF-8
class RanameAreaToConfigurations < ActiveRecord::Migration
  def change
    rename_column :configurations, :area, :config_groups_id
    add_index :configurations, :config_groups_id
  end
end
