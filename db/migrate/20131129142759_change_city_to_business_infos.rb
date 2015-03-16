class ChangeCityToBusinessInfos < ActiveRecord::Migration
  def change
    remove_column :business_infos, :city_id
    add_column :business_infos, :city, :string, :limit => 100
  end
end
