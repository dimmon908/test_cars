#encoding: utf-8
class CreateCarPhotos < ActiveRecord::Migration
  def change
    create_table :car_photos, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.references :car
      t.string :photo

      t.timestamps
    end
    add_index :car_photos, :car_id
  end
end
