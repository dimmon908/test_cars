class ChangeFailtFieldInEmailsPull < ActiveRecord::Migration
  def change
    rename_column :emails_pulls, :failt_stamp, :fail_stamp
  end
end
