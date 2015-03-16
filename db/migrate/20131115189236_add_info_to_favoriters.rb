class AddInfoToFavoriters < ActiveRecord::Migration
  def change
    add_column :favorites, :street, :string, :limit => 100
    add_column :favorites, :city, :string, :limit => 100
  end
end
