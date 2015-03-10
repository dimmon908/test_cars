#encoding: utf-8
class ChangeDateToRequests < ActiveRecord::Migration
  def change
    change_column :requests, :date, :string
  end
end
