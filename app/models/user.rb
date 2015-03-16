#encoding: utf-8
require 'devise'
require_relative '../../config/initializers/devise'
class User < ActiveRecord::Base
  self.per_page = 10

  NAME_REGEXP = /\A[A-Za-zА-Яа-я \s'"]+\z/
  DATE_REGEXP = /\A[\d]{1,2}\/[\d]{1,2}\z/
  EMAIL_REGEXP = /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/

  belongs_to :user_profile
  belongs_to :card
  belongs_to :role
  belongs_to :favorites
  belongs_to :partner, :class_name => User
  belongs_to :business_info

  has_many :authenticationses

  after_initialize :after_initialize_callback

  before_create :before_create_callback
  after_create :after_create_callback

  before_save :before_save_callback
  before_update :before_save_callback
  after_save :after_save_callback
  before_validation :before_validate_callback

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, #:confirmable,
         :omniauthable, :omniauth_providers => [:facebook, :twitter, :linkedin]

  extend Excluded::User

  include Notify::User
  include ModelValidators::User
  include Payment::User
  include Omnioauth::User
  include Included::User
  include Included::Role
  include Included::Profile
  include Included::Changes
  include Included::Api
  include Included::PaymentMethod

  validates :first_name, :presence => true, :length => { :within => 2..50 }
  validates_format_of       :first_name, :with  => NAME_REGEXP, :allow_blank => true

  validates :last_name, :presence => true, :length => { :within => 2..50 }
  validates_format_of       :last_name, :with  => NAME_REGEXP, :allow_blank => true

  validates_presence_of   :phone
  validates_uniqueness_of :phone, :allow_blank => true

  validates_presence_of   :email
  validates_uniqueness_of :email, :allow_blank => true

  validates :password, :confirmation => true

  attr_accessible :email, :password, :password_confirmation, :remember_me, :phone, :username, :phone_code,
                  :country, :first_name, :last_name, :zip_code, :photo, :gender, :age, :params, :comments,
                  :uid, :provider, :token, :token_secret,
                  :confirmed_at, :confirmation_sent_at, :confirmation_token, :unconfirmed_email, :birth_date,
                  :approve, :payment,
                  :device, :device_id, :online, :can_receive_request,
                  :partner_id, :show

  attr_accessor  :first_name, :last_name, :user_profile,
                 :zip_code, :photo, :phone_code, :gender, :age, :params, :comments, :birth_date, :country,
                 :uid, :provider, :token, :token_secret, :last_access,
                 :current_password, :email_new, :phone_new,
                 :confirmed_at, :confirmation_sent_at, :confirmation_token, :unconfirmed_email, :payment,
                 :device, :device_id, :online,
                 :find_element

  # @return [User]
  def self.find_for_authentication(conditions={})
    unless conditions[:email] =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
      if conditions[:email] =~ /^([\d\+\-\(\)]+)$/i
        conditions[:phone] = conditions.delete(:email)
      else
        conditions[:username] = conditions.delete(:email)
      end
    end
    super
  end

  def developer?
    email && email == 'dmitriy.svinin@gmail.com'
  end

  def approved?
    self.approve
  end

  def profile
    if user_profile.blank?
      if self.id
        self.user_profile = UserProfile::find_or_create_by_user_id id
      else
        self.user_profile = UserProfile.new
      end
    end
    user_profile
  end

  def name
    full_name
  end

  protected
  #<<<<<<<<<<<<<<<<<------callbacks---------
  def after_initialize_callback
    get_additional_info
    #self.phone = "#{self.phone_code}#{self.phone}"
    self.username = email if username.blank?
    self.partner_id ||= id if id
    self.payment ||= default_payment
    self.params ||= {}
  end
  def before_create_callback
    create_role
    self.payment ||= default_payment
    self.status = 1
    self.can_receive_request ||= false
    true
  end
  def after_create_callback
    create_profile
  end
  def before_save_callback
    self.partner_id = id unless partner_id

    if !phone.blank? && phone_code
      old_code = user_profile.phone_code.to_s.scan(/\+?\d+/).join('')
      phone.gsub!(Regexp.new('\\' + old_code.to_s), '') unless old_code.blank?

      code = phone_code.scan(/\+?\d+/).join('')
      self.phone = "#{code}#{phone}" unless phone.to_s.include?(code)
    end
    true
  end
  def after_save_callback
    save_additional_info
  end

  def before_validate_callback
    self.first_name = self.first_name.to_s.strip if first_name
    self.last_name = self.last_name.to_s.strip if last_name
  end
  #<<<<<<<<<<<<<<<<<------callbacks---------

  def get_additional_info
    load_profile
    create_role
  end

  def save_additional_info
    save_profile
  end
end