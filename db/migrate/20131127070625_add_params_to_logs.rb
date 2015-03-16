class AddParamsToLogs < ActiveRecord::Migration
  def change
    add_column :logs, :request, :string
    add_column :logs, :session, :text
    add_column :logs, :params, :text
  end
end
