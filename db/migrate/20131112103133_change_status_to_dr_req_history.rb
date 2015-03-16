# encoding: UTF-8
class ChangeStatusToDrReqHistory < ActiveRecord::Migration
  def change
    change_column :driver_activity_histories, :status, :string, :limit => 30
    change_column :driver_request_histories, :status, :string, :limit => 30
  end
end
