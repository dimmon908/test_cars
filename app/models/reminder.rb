class Reminder < ActiveRecord::Base
  before_save :before_save

  belongs_to :user
  attr_accessible :date, :rm_hash, :name, :user, :user_id

  private
  def before_save
    date ||= Time.now
  end
end
