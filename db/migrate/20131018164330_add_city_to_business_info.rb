#encoding: utf-8
class AddCityToBusinessInfo < ActiveRecord::Migration
  def change
    add_column :business_infos, :city_id, :integer
    add_index :business_infos, :city_id
  end
end
