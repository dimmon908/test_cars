# encoding: UTF-8
class AddAttachmentPhotoToCarPhotos < ActiveRecord::Migration
  def self.up
    change_table :car_photos do |t|
      t.remove :photo
    end

    change_table :car_photos do |t|
      t.attachment :photo
    end
  end

  def self.down
    add_column :car_photos, :photo, :string
    drop_attached_file :car_photos, :photo
  end
end
