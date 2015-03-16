class AddBirthdateToUserProfile < ActiveRecord::Migration
  def change
    add_column :user_profile, :birth_date, :datetime
  end
end
