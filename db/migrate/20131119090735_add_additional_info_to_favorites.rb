class AddAdditionalInfoToFavorites < ActiveRecord::Migration
  def change
    add_column :favorites, :additional, :binary
  end
end
