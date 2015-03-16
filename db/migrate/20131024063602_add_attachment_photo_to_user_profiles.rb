# encoding: UTF-8
class AddAttachmentPhotoToUserProfiles < ActiveRecord::Migration
  def self.up
    change_table :user_profile do |t|
      t.attachment :photo
    end
  end

  def self.down
    drop_attached_file :user_profile, :photo
  end
end
