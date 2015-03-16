#encoding: utf-8
class AddZipCodeToBusinessInfo < ActiveRecord::Migration
  def change
    add_column :business_infos, :zip_code, :string, :limit => 10
  end
end
