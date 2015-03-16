class AddCreditToUserProfile < ActiveRecord::Migration
  def change
    add_column :user_profile, :credit, :decimal, :precision => 12, :scale => 2
  end
end
