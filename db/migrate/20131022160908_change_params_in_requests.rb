#encoding: utf-8
class ChangeParamsInRequests < ActiveRecord::Migration
  def change
    change_column :requests, :params, :binary
  end
end
