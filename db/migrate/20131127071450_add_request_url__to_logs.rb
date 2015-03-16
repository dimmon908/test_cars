class AddRequestUrlToLogs < ActiveRecord::Migration
  def change
    add_column :logs, :request_url, :string, :limit => 50
  end
end
