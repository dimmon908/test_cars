class AddPhoneCodeToUserProfile < ActiveRecord::Migration
  def change
    add_column :user_profile, :phone_code, :integer
  end
end
