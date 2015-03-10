#encoding: utf-8

class Request < ActiveRecord::Base
  scope :active, -> { where('status IN (?)', Trip::Status::ACTIVE) }
  scope :instant, -> { where('status = ?', Trip::Status::INSTANT) }
  scope :finished, -> { where('status = ?', Trip::Status::FINISHED) }
  scope :future_flag_0, -> { where('future_flag is null or future_flag = 0') }
  scope :future_flag_1, -> { where('future_flag = 1') }
  scope :past, -> { where('status IN (?)', Trip::Status::PAST) }
  scope :active_list, -> { where('status IN (?) OR (status IN (?) and date > ?)', Trip::Status::ACTIVE, Trip::Status::PAST, Time.now.beginning_of_day) }
  scope :future, -> { where('status = ?', Trip::Status::FUTURE) }
  scope :by_partner, ->(id) { where('`partner_id` = ?', id) }
  scope :by_user, ->(id) { where('`user_id` = ?', id) }
  scope :by_driver, ->(id) { where('`driver_id` = ?', id) }
  scope :dates, ->(from, to) { where('date > ? AND date < ?', from.strftime('%Y-%m-%d 00:00'), to.strftime('%Y-%m-%d 23:59')) }
  scope :active_driver, ->(id) { by_driver(id).active }
  scope :active_user, ->(id) { by_user(id).active }
  scope :before_date, ->(date) {where('`date` <= ?', date)}

  DATE_REGEXP       = /\d{1,2}\/\d{1,2}\/\d{1,4} \- \d{1,2}:\d{1,2} [AM|PM]/
  TIME_STAMP_REGEXP = /^\d+$/
  DB_DATE_REGEXP    = /\d{1,4}\-\d{1,2}\-\d{1,2} \d{1,2}:\d{1,2}/

  DATE_FORMAT       = '%m/%d/%Y - %H:%M %p'
  DB_DATE_FORMAT    = '%Y-%m-%d %H:%M'
  TIME_STAMP_FORMAT = '%s'

  ACTIVE = [:started, :accept, :waiting, :instant]
  PAST   = [:canceled, :finished, :error, :unauth]
  FUTURE = :future

  belongs_to :user
  belongs_to :partner, :class_name => User, :foreign_key => :partner_id
  belongs_to :cancelled_user, :class_name => User, :foreign_key => :cancelled_user_id
  belongs_to :driver
  belongs_to :car
  belongs_to :promo_code
  belongs_to :vehicle

  include RequestExt::ExportCsv
  include Notify::Request
  include Included::Transaction
  include Included::Payment
  include Included::Coordinates
  include Included::Distance
  include Trip::Check
  include Trip::StatusChanges
  include ActionView::Helpers::NumberHelper


  attr_accessible :comment, :date, :from, :luggage, :params, :passengers, :payment_options, :rate, :reserve_number, :status, :to, :vehicle_id, :promo,
                  :user_id, :user,
                  :distance, :real_time, :real_distance, :time, :phone, :payment, :future_flag,
                  :recommended_first_name, :recommended_last_name, :recommended_phone, :recommended_room, :recommended_reference

  attr_accessor :promo, :payment,
                :recommended_first_name, :recommended_last_name, :recommended_phone, :recommended_room, :recommended_reference,
                :client_validation

  attr_writer :transaction

  before_save :before_save_callback
  before_create :before_create_callback
  after_initialize :after_initialize_callback
  after_save :after_save_callback
  after_create :after_create_callback

  validates :date, :request_status_time => true

  validates :from, :presence => true, :geofence => true
  validates :vehicle_id, :presence => true

  validates :promo, :promo_code => true, :allow_blank => true
  validates :status, :request_status => true, :driver_available => true
  validates :user_id, :business_terms_application_approval => true
  validates :to, :request_places => true

  validates :recommended_first_name, :presence => {:if => :need_validate_recommend?}
  validates :recommended_last_name, :presence => {:if => :need_validate_recommend?}
  validates :recommended_phone, :presence => {:if => :need_validate_recommend?}

  #@param [User] user
  #@param [String] filter
  def next(user, filter = nil)
    query = "`id` > #{id}"
    query += " AND partner_id = #{user.partner_id} " unless Role::admin? user
    if filter.to_s == 'future'
      query += " AND status = 'future' "
    elsif filter.to_s == 'instant'
      query += " AND status != 'future'"
    end
    Request::where query
  end

  #@param [User] user
  #@param [String] filter
  def previous(user, filter = nil)
    query = "`id` < #{id}"
    query += " AND partner_id = #{user.partner_id} " unless Role::admin? user
    if filter.to_s == 'future'
      query += " AND status = 'future' "
    elsif filter.to_s == 'instant'
      query += " AND status != 'future'"
    end
    Request::where(query).order('id DESC')
  end

  def before_cancel_time
    return nil unless booked
    time = (future_flag? ? (date + Configurations[:cancel_no_fee_time]) : (booked + Configurations[:cancel_no_fee_time])) - Time.now
    time = 0 if time < 0
    time
  end

  # @deprecated
  def authorize_payment
    begin
      return nil unless self.need_auth_pay?
      #return nil unless user.card

      user = User::user_object_by_role(self.user.role, self.user.id)
      card = Card.find_by_user_id user.id

      info.error("\n\n\n\n\n\n\n\n\n:: authorize payment: this is transaction full price: #{transaction.full_price}")
      info.error(YAML::dump(self))
      info.error("\n\n\n\n\n\n\n\n\nself   :::::::::::::::::::::::::::::::")
      info.error(YAML::dump(self.transaction))
      info.error("\n\n\n\n\n\n\n\n\ntransaction     :::::::::::::::::::::::::::::::")

      #sim = AuthorizeNet::SIM::Transaction.new(AUTHORIZE_NET_CONFIG['api_login_id'],AUTHORIZE_NET_CONFIG['api_transaction_key'], self.transaction.full_price, :relay_url => "#{request.host}/payments/response")
      sim = AuthorizeNet::SIM::Transaction.new(AUTHORIZE_NET_CONFIG['api_login_id'], AUTHORIZE_NET_CONFIG['api_transaction_key'], self.transaction.full_price, :relay_url => 'http://ondemand.test.cc/payments/response')
      sim.authorize self.transaction.full_price, card.card_number


      params                = sim.form_fields
      params[:x_card_num]   = card.card_number
      params[:x_exp_date]   = card.card_expire.strftime('%m%y')
      params[:x_card_code]  = card.cvv
      params[:x_first_name] = user.first_name
      params[:x_last_name]  = user.last_name
      params[:x_trans_id]   = transaction.id
      params[:x_type]       = 'AUTH_ONLY'
      url                   = AuthorizeNet::SIM::Transaction::Gateway::TEST

      sim_response = AuthorizeNet::SIM::Response.new(JSON.parse(Net::HTTP.post_form(URI.parse(url.to_s), params).body))

      if sim_response.approved?
        transaction.status             = :approve
        transaction.authorization_code = sim_response.authorization_code
        transaction.save
      end


      sim_response
    rescue Exception => e
      Log.exception e
    end
  end

  def get_user
    unless self.user
      self.user = User::find self.user_id rescue nil
    end
    self.user
  end

  # @return [DateTime]
  def datetime_date(date = nil)
    date ||= self.date

    if date.is_a? String
      if date.to_s =~ TIME_STAMP_REGEXP
        return Time.strptime(date, TIME_STAMP_FORMAT)
      elsif date.to_s =~ DB_DATE_REGEXP
        return Time.strptime(date, DB_DATE_FORMAT)
      elsif date.to_s =~ DATE_REGEXP
        return Time.strptime(date, DATE_FORMAT)
      end
    end

    date
  end

  def need_validate_recommend?
    return true if self.client_validation
    recommend? && Trip::Status::instant?(self)
  end

  def recommend?
    begin
      return true if params['recommend'].to_i > 0
      nil
    rescue Exception => e
      Log.exception e
      nil
    end
  end

  def estimated
    return '' unless time

    HelperTools::format_time time
  end

  def remain_time
    return false unless eta
    time = eta - Time.now

    HelperTools::format_time time
  end

  def add_info
    return nil unless Trip::Status::active? self
    return nil unless driver

    { :driver  => driver.to_js, :request => to_js }
  end

  def to_js
    data = {
        :id          => id,
        :notes       => comment,
        :rate        => rate,
        :date        => date.strftime(DATE_FORMAT),
        :coordinates => coordinates,
    }

    if Trip::Status::accepted? self
      data[:eta] = remain_time
    else
      data[:eta] = ''
    end

    data
  end

  def additional_info
    _date = 0
    _date = date.to_time.to_i rescue 0 if future_flag

    resp = {
        :id => id,
        :pickup_address => from, :pickup_latitude => from_coord['lat'], :pickup_longitude => from_coord['lng'],
        :destination_address => to.last, :destination_latitude => to_coord['lat'], :destination_longitude => to_coord['lng'],
        :customer_info => passenger_info,
        :eta => eta,
        :account_billed_credit_card => passenger_credit_card? || credit_card?,
        :estimated_cost => rate.to_f,
        :luggage => luggage,
        :number_of_passengers => passengers,
        :trip_status => status,
        :special_requests => comment,
    }
    resp[:date] = _date if _date > 0
    resp.merge!({ :distance => params['distance'], :start_time => params['start_time'], :distance_calc => true }) if params['distance']
    resp.merge!({ :distance => params[:distance], :start_time => params[:start_time], :distance_calc => true }) if params[:distance]
    resp.merge!({ :lat => driver.latitude, :lng => driver.longitude, :driver_id => driver.id }) if driver
    resp
  end

  def passenger_info
    if recommend?
      {
          :first_name   => recommended_first_name,
          :last_name    => recommended_last_name,
          :phone_number => recommended_phone,
          :photo_url    => nil
      }
    else
      {
          :first_name   => user.first_name,
          :last_name    => user.last_name,
          :phone_number => user.phone,
          :photo_url    => user.photo.url(:medium)
      }
    end
  end

  def check_date
    return if self.error? || self.canceled?
    date = datetime_date

    self.instant! if self.future? && date < (DateTime.now + Configurations[:future_request_pickup_time].to_i.minutes)
  end

  def alt_handle
    check_distance
    check_promo
    check_recommend
    check_to
    self.vehicle = Vehicle::find vehicle_id if vehicle_id.to_i > 0 && vehicle_id != vehicle.id
    calculate_rate if rate.to_i < 1
    self.partner_id = user.partner_id if user
  end

  def before_save_callback
    check_distance

    check_date_save
    check_promo

    begin
      check_recommend

      params['payment'] = payment.to_s if payment

      self.params = MessagePack.pack params if params.is_a?Hash
      self.vehicle = Vehicle::find vehicle_id if vehicle_id.to_i > 0 && vehicle_id != vehicle.id

      calculate_rate if rate.to_i < 1

      self.partner_id = user.partner_id if user
    rescue Exception => e
      Log.exception e
    end
  end

  def before_create_callback
    self.date = Time.now if Trip::Status::instant? self
    self.future_flag = true if Trip::Status::future? self
  end

  def after_initialize_callback
    init

    check_real_time

    if future_flag.nil?
      self.future_flag = true if Trip::Status::future? self
      self.future_flag ||= false
    end

    self.date ||= Time.now
    self.vehicle ||= Vehicle::first

    self.to ||= [nil]

    get_transaction if id
    self.driver = Driver::find(driver_id) if driver.blank? &&  driver_id.to_i > 0 && Driver.where(:id => driver_id).any?

    params['passengers'] ||= [0 => {}]

    if recommend?
      self.recommended_last_name ||= params['passengers'][0]['last_name'] rescue nil
      self.recommended_first_name ||= params['passengers'][0]['name'] rescue nil
      self.recommended_phone ||= params['passengers'][0]['phone'] rescue nil
      self.recommended_room ||= params['passengers'][0]['room'] rescue nil
      self.recommended_reference ||= params['passengers'][0]['reference'] rescue nil
    end

    self.client_validation ||= false

    self.payment ||= self.params['payment']
    self.payment ||= Payment::Type::CREDIT_CARD

    self.rate = params['estimated_rate'] if params['estimated_rate']

    self.partner_id = user.partner_id if user
    self.car = driver.car if driver
  end

  def after_create_callback
    self.get_transaction
  end

  def after_save_callback
    init

    if transaction
      transaction.base = rate
      transaction.save :validate => false
    end

  end

  def init

    self.params = MessagePack.unpack params if params.is_a? String
    self.params ||= {:from_coordinates.to_s => {}, :to_coordinates_0.to_s => {}}

    params.delete 'to_coordinates___i__' if params['to_coordinates___i__']

    #self.date = self.date.strftime DATE_FORMAT if self.date.is_a?DateTime
    self.date = datetime_date if !date.blank? && date.is_a?(String)

    self.status ||= Trip::Status::INSTANT

    check_to

    self.payment ||= params['payment'] unless params.blank? && params['payment'].blank?

  end

  def check_to
    if !to.blank? && to.is_a?(String)
      val = MessagePack::unpack(to.force_encoding(Encoding::BINARY)) rescue nil
      val     = val.values if val.is_a?(Hash)
      self.to = val if val
      self.to = [to] if to.is_a? String
    end

    self.to = to.values if to.is_a?Hash
  end
end