#encoding: utf-8
class UserProfile < ActiveRecord::Base
  scope :online, -> { where(:online => 1) }
  scope :last_api_access, ->(time) {where('last_access IS NULL OR last_access < ?', time)}
  scope :over_credit, ->(from) { where('credit/credit_limit > ?', from) }
  scope :less_credit, ->(to) { where('credit/credit_limit < ?', to) }
  scope :reminder, ->(name) { where('NOT EXISTS(SELECT 1 FROM `reminders` r WHERE r.user_id = user_profile.user_id AND name = ? and rm_hash = credit)', name) }

  self.table_name = :user_profile

  belongs_to :user

  before_save :before_save
  after_save :after_save
  after_initialize :after_init

  attr_accessible :first_name, :last_name, :zip_code, :photo, :phone_code, :gender, :age, :comments, :params, :device_id, :birth_date, :payment, :credit, :credit_limit

  has_attached_file :photo, :styles => { :small => '35x35>', :medium => '300x300>'},
                    :url  => '/img/upload/client/:id/:style/:basename.:extension',
                    :path => ':rails_root/public/img/upload/client/:id/:style/:basename.:extension',
                    :default_url => '/img/missing-avatar.png'


  validates_attachment_size :photo, :less_than => 5.megabytes
  validates_attachment_content_type :photo, :content_type => %w(image/jpeg image/png)

  def can_credit?(amount)
    return true if credit_limit.to_i == 0 || user.can_receive_request?
    (credit_limit.to_f - credit.to_f) > amount.to_f
  end

  def api_logout
    #self.device_id = nil
    #self.device = nil
    self.online = 0
    save :validate => false
  end

  private
  def before_save
    self.params = MessagePack.pack params rescue nil
  end

  def after_init
    init_params
  end

  def after_save
    init_params
  end

  def init_params
    begin
      self.params = MessagePack.unpack params
    rescue Exception => e
      self.params = nil
    end
    self.params = {} unless params.is_a?Hash
  end
end