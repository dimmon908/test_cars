#encoding: utf-8
class AddPhotoToUserProfle < ActiveRecord::Migration
  def change
    add_column :user_profile, :photo, :string
  end
end
