#encoding: utf-8
class AddSuiteToBusinessInfo < ActiveRecord::Migration
  def change
    add_column :business_infos, :suite, :string, :limit => 20
  end
end
