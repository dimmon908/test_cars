# encoding: UTF-8
class RemovePhotoToUsers < ActiveRecord::Migration
  def change
    change_table :user_profile do |t|
      t.remove :photo
    end
  end
end
