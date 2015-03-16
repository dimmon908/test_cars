class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.references :user
      t.string :address
      t.float :latitude
      t.float :longitude
      t.integer :sort_order
      t.boolean :enabled

      t.timestamps
    end
    add_index :favorites, :user_id
  end
end
