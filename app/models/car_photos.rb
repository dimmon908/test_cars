#encoding: utf-8
class CarPhotos < ActiveRecord::Base
  belongs_to :car
  attr_accessible :photo, :car_id

  has_attached_file :photo, :styles => { :small => '35x35>', :medium => '300x300>'},
                    :url  => "/img/upload/car/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/img/upload/car/:id/:style/:basename.:extension",
                    :default_url => '/img/missing-avatar.png'

  validates_attachment_presence :photo
  validates_attachment_size :photo, :less_than => 5.megabytes
  validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png']
end
