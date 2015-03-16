class AddLastDriverApiAccess < ActiveRecord::Migration
  def change
    add_column :drivers, :last_access, :datetime
  end
end
