# encoding: UTF-8
class AddCoordinatesToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :route, :binary
    add_column :requests, :eta, :float
  end
end
