class AddOnlineToUsers < ActiveRecord::Migration
  def change
    add_column :user_profile, :online, :boolean
  end
end
