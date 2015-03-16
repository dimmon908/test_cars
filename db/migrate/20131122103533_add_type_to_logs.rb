class AddTypeToLogs < ActiveRecord::Migration
  def change
    add_column :logs, :log_type, :string, :limit => 15
  end
end
