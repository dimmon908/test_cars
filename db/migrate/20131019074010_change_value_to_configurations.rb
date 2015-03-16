#encoding: utf-8
class ChangeValueToConfigurations < ActiveRecord::Migration
  def change
    change_column :configurations, :value, :binary
  end
end
