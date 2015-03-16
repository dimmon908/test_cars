class ChangePhoneCodeToUsersProfile < ActiveRecord::Migration
  def up
    change_column :user_profile, :phone_code, :string, :limit => 60
  end
end
