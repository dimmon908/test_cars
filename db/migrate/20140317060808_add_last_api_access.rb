class AddLastApiAccess < ActiveRecord::Migration
  def change
    add_column :user_profile, :last_access, :datetime
  end
end
