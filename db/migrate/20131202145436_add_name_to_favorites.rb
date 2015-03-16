class AddNameToFavorites < ActiveRecord::Migration
  def change
    add_column :favorites, :name, :string, :limit => 100
  end
end
