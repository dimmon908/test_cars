class AddTitleToLogs < ActiveRecord::Migration
  def change
    add_column :logs, :title, :string, :limit => 100
  end
end
