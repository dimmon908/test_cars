class AddCreditLimitToUserProfile < ActiveRecord::Migration
  def change
    add_column :user_profile, :credit_limit, :float
  end
end
