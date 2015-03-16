class Favorites < ActiveRecord::Base
  belongs_to :user
  attr_accessible :address, :enabled, :latitude, :longitude, :sort_order, :user_id, :city, :street, :user, :name, :additional

  geocoded_by :address
  after_validation :geocode, :if => :address_changed?

  after_initialize :after_init
  before_save :before_save

  private
  def after_init
    self.additional = MessagePack::unpack(additional) if self.additional
  end

  def before_save
    self.additional = MessagePack::pack(additional) if self.additional
  end
end
