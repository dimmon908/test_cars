# encoding: UTF-8
class AddDescrToConfigGroups < ActiveRecord::Migration
  def change
    add_column :config_groups, :desc, :string
  end
end
