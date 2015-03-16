#encoding: utf-8
class ChangeBusinessTypeToBusinessInfo < ActiveRecord::Migration
  def change
    change_column :business_infos, :type, :string, :limit => 20
  end
end
