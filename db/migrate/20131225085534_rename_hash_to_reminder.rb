class RenameHashToReminder < ActiveRecord::Migration
  def change
    rename_column :reminders, :hash, :rm_hash
  end
end
