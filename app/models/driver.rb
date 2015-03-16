#encoding: utf-8

class Driver < ActiveRecord::Base
  scope :online, -> {where(:online => 1)}
  scope :last_api_access, ->(time) {where('last_access is NULL OR last_access < ?', time)}
  scope :booked, -> {online.where('status IN (?)', Chauffeur::Status::DRIVER_BOOKED)}
  scope :available, -> {online.where(:status => Chauffeur::Status::ACTIVE)}
  scope :unavailable, -> {online.where(:status => Chauffeur::Status::DISABLED)}
  scope :unlock, -> {where('`lock` = 0 OR `lock` IS NULL')}

  include DriverExt::ExportCsv
  DATE_REGEXP = /\d{1,4}\-\d{1,2}\-\d{1,2}/
  DATE_FORMAT = '%Y-%m-%d'

  belongs_to :user, :class_name => 'Classes::DriverAccount'
  belongs_to :car

  attr_accessible :age_group, :enabled, :gender, :license_expore, :license_number, :second_lang, :status, :status_changed, :temp_password, :latitude, :longitude, :gmaps, :user_id, :alt_phone

  attr_accessor :first_name, :last_name, :email, :phone, :photo, :birth_date
  attr_accessible :first_name, :last_name, :email, :phone, :photo, :birth_date, :lock

  acts_as_gmappable :process_geocoding => false

  after_initialize :after_initialize_callback
  after_save :after_save

  before_create :before_create_callback
  before_save :before_save_callback

  validates :first_name, :presence => true, :length => { :within => 2..50 }
  validates_format_of       :first_name, :with  => User::NAME_REGEXP, :allow_blank => true
  validates :last_name, :presence => true, :length => { :within => 2..50 }
  validates_format_of       :last_name, :with  => User::NAME_REGEXP, :allow_blank => true

  validates_presence_of   :phone

  validates :email, :user_email => true
  validates :phone, :user_phone => true
  validates_presence_of   :email
  validates_format_of     :email, :with  => User::EMAIL_REGEXP, :allow_blank => true

  validates :license_expore, :date => [Time.now]
  #validates_presence_of     :license_expore
  validates_format_of       :license_expore, :with  => DATE_REGEXP, :allow_blank => true
  validates_format_of       :birth_date, :with  => DATE_REGEXP, :allow_blank => true

  def send_push_message(message, from=nil)
    return nil unless device_id

    device = Device::device device_id
    return nil unless device

    Device::send_notification(
        device,
        {:data => {:from => from.to_i, :request_type => :manually, :message => message.to_s}},
        "driver_message [#{id}]"
    )
  end

  def self.for_map
    {
      summary: {
        :available => available.count,
        :unavailable => unavailable.count,
        :booked => booked.count,
        :total => online.count
      },
      drivers: {
          :available => available.all.collect {|driver| driver.to_js},
          :booked => booked.all.collect {|driver| driver.to_js},
          :unavailable => unavailable.all.collect {|driver| driver.to_js}
      }
    }
  end

  def api_logout
    #self.device_id = nil
    #self.device = nil
    self.online = 0
    save :validate => false
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  # @return [Hash]
  def get_coordinates
    {'lat' => latitude.to_f, 'lng' => longitude.to_f}
  end

  def to_js
    data = {
        :id => id,
        :coordinates => {:lat => latitude.to_f, :lng => longitude.to_f},
        :name => full_name,
        :first_name => first_name,
        :last_name => last_name,
        :photo => photo,
        :car_type => car.vehicle.name,
        :car => {
            :url => car.vehicle.photo,
            :name => car.vehicle.name,
            :desc => car.vehicle.desc,
        }
    }

    if Chauffeur::Status.booked?(self) && Request.active_driver(id).any?
      request = Request.active_driver(id).first
      data[:request] = request.to_js
    end

    if self.status.to_sym == Chauffeur::Status::DISABLED
      relation = DriverActivityHistory::where('driver_id = ? AND status = ? and created_at > ?',
                                              id,
                                              Chauffeur::Status::DISABLED,
                                              Time.now.at_beginning_of_day)

      row = relation.order('created_at DESC').first
      if row
        time = row.created_at + 10.minute - Time.now
        data[:break] = {
          :count => relation.count,
          :left => HelperTools::format_time(time)
        }
      else
        data[:break] = {
          :count => relation.count,
          :left => HelperTools::format_time(10.minute)
        }
      end

    end

    data
  end

  def role
    user.role
  end

  def email_confirm
  end

  def gmaps4rails_address
    'San Francisco, CA, United States'
  end

  def api_token
    user.api_token
  end
  def api_token=(value)
    user.api_token = value
  end

  def token_expire
    user.token_expire
  end
  def token_expire=(value)
    user.token_expire = value
  end

  def name
    "#{user.last_name} #{user.first_name} - #{id}" rescue "#{I18n.t('general.driver')} - #{id}"
  end

  def basic_info
    {
      :id => id,
      :driver_user_id => user_id,
      :first_name => first_name.to_s,
      :last_name => last_name.to_s,
      :photo =>  user.profile.photo.url(:medium),
      :age => age_group.to_s,
      :gender => gender.to_s,
      :license_expire => license_expore.to_s,
      :license_number => license_number.to_s,
      :second_lang => second_lang.to_s,
      :phone => phone
    }
  end

  def additional_info
    resp = {
        :plates => Car::available.all.collect{|p| p.to_js},
        :driver_status => status
    }
    if Request.active_driver(id).any?
      request = Request.active_driver(id).first
      resp[:active_request] = true
      resp[:request_id] = request.id
      resp[:request_status] = request.status
      resp[:request] = request.additional_info
    end
    resp[:active_request] ||= false
    resp
  end

  def self.enabled_drivers
    return Driver::online.all.to_gmaps4rails
  end

  def load_user
    if user.nil? && user_id
      self.user = Classes::DriverAccount::find user_id
      user.driver = self
    end
    user
  end

  def get_car
    begin
      self.car = Car.find car_id rescue nil if car.blank? && car_id.blank?
      self.car = Car.first if car.blank?
    rescue Exception => e
      Log.exception e
    end
    car
  end


  protected

  def create_driver
    return user if user
    begin
      if user_id.nil?
        user = Classes::DriverAccount.create({
                                                 :email => email,
                                                 :first_name => first_name,
                                                 :last_name => last_name,
                                                 :phone => phone,
                                                 :password =>  Configurations[:default_driver_password]
                                             })
        if user
          self.user_id = user.id
          self.user = user
          self.user.driver = self
        end
      else
        self.user = Classes::DriverAccount::find(user_id)
        self.user.driver = self
      end
      self.user
    rescue Exception => e
      Log.exception e
    end
  end

  def before_create_callback
    self.lock ||= false
    create_driver
  end

  def before_save_callback
    if birth_date.is_a?(String) and birth_date =~ DATE_REGEXP
      self.birth_date = DateTime::strptime birth_date, DATE_FORMAT
    end

    if license_expore.is_a?(String) and license_expore =~ DATE_REGEXP
      self.license_expore = DateTime::strptime license_expore, DATE_FORMAT
    end

    if (user || create_driver) && first_name
      user.password = '' if user.password.nil?
      user.first_name = first_name
      user.last_name = last_name
      user.email = email
      user.phone = phone
      user.photo = photo
      user.birth_date = birth_date
      user.save :validate => false
    end

    user
  end

  def after_save
    self.birth_date = birth_date.strftime(DATE_FORMAT) if birth_date.is_a?DateTime
    self.license_expore = license_expore.strftime(DATE_FORMAT) if license_expore.is_a?DateTime
  end

  def after_initialize_callback
    begin
      self.license_expore = license_expore.strftime(DATE_FORMAT) if license_expore.is_a?ActiveSupport::TimeWithZone
      if (first_name.blank?) && (user_id.to_i > 0 && create_driver)
        self.first_name = user.first_name
        self.last_name = user.last_name
        self.email = user.email
        self.phone = user.phone
        self.birth_date = user.birth_date
        self.photo = user.photo
      end
      self.birth_date = birth_date.strftime(DATE_FORMAT) if birth_date.is_a?ActiveSupport::TimeWithZone
      self.status ||= :offline
      #self.status = :offline if online.blank?
    rescue
      nil
    end
    get_car
  end
end