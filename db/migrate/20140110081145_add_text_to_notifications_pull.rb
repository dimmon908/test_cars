class AddTextToNotificationsPull < ActiveRecord::Migration
  def change
    add_column :notification_pulls, :text_field, :string
  end
end
