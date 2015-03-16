class AddInfoToUserProfile < ActiveRecord::Migration
  def change
    add_column :user_profile, :gender, :string, :limit => 15
    add_column :user_profile, :age, :integer
    add_column :user_profile, :comments, :string
    add_column :user_profile, :params, :binary
  end
end
