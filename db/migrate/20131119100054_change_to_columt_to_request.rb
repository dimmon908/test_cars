class ChangeToColumtToRequest < ActiveRecord::Migration
  def change
    change_column :requests, :to, :binary
  end
end
