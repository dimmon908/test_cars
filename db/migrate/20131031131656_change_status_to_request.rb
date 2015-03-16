# encoding: UTF-8
class ChangeStatusToRequest < ActiveRecord::Migration
  def change
    change_column :requests, :status, :string, :limit => 30
  end
end
