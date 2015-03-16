# encoding: UTF-8
class ChangeTypeColumnToBusiness < ActiveRecord::Migration
  def change
    rename_column :business_infos, :type, :type_name
  end
end
