class DriverController < ApplicationController

  def initialize
    @resp = {}
    @user = nil
    # @param [Driver] @driver
    @driver = nil
    @trip = nil
  end


  # GET/POST
  def drivers_map
    begin
      render json: {status: :ok, data: Driver.for_map }
    rescue Exception => e
      log_exception e
      render json: {status: :internal_server_error, :message => e.to_s }
    end
  end

  def troubles
    respond_to do |format|
      format.html {}
      format.json {

        begin
          data = JSON::parse params[:data]
          validate data
          return unless @driver

          @resp = {:status => :ok}
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  def cars
    respond_to do |format|
      format.html {}
      format.json {

        begin
          data = JSON::parse params[:data]
          validate data
          return unless @driver


          @resp = {:status => :ok, :plates => Car.available.all.collect{|p| p.to_js}}
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  def available_car

  end

  def plate
    respond_to do |format|
      format.html {}
      format.json {

        begin
          data = JSON::parse params[:data]
          validate data
          return unless @driver

          (@resp = {:status => :bad_request, :message => t('api.errors.invalid_plate_number')}) and
              return unless Car::where(:id => data['plate_number']).any?

          car = Car::find data['plate_number']
          (@resp = {:status => :conflict, :message => t('api.errors.occupied_car')}) and
              return if Driver::where('`car_id` = ? AND `id` != ? AND online = 1', car.id, driver.id).any?

          driver.car = car
          driver.status = Chauffeur::Status::ACTIVE unless Chauffeur::Status.booked?(driver)
          (@resp = {:status => :not_acceptable, :message => t('api.errors.driver_save', :errors => driver.errors.messages.to_s)}) and
              return unless driver.save

          history = DriverCarHistory::create({
              :driver => driver,
              :car => car,
              :status => :assign,
              :comment => :assign_by_api
          })

          (@resp = {:status => :not_acceptable, :message => t('api.errors.history_save', :errors => history.errors.messages.to_s)}) and
              return unless history

          ActiveRecord::Base.connection.execute("UPDATE drivers SET car_id = NULL WHERE car_id = #{data['plate_number']} AND online = 0")

          @resp = {:status => :ok}
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  def status
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless driver

          if data['active']
            status = data['status'] ? Chauffeur::Status::ACTIVE : Chauffeur::Status::DISABLED
            driver.status = status
          else 
            status = nil
            driver.status = status
            driver.car = nil
          end
          
      
          (@resp = {:status => :not_acceptable, :message => t('api.errors.driver_save', :errors => driver.errors.messages.to_s)}) and
              return unless driver.save

          history = DriverActivityHistory.create({:status => status, :driver => driver})

          (@resp = {:status => :not_acceptable, :message => t('api.errors.history_save', :errors => history.errors.messages.to_s)}) and
              return unless history.save

          @resp = {:status => :ok}
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  def location
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless driver

          (@resp = {:status => :bad_request, :message => t('api.errors.invalid_request')}) and
              return unless data['latitude'] && data['longitude']

          driver.latitude = data['latitude'].to_f
          driver.longitude = data['longitude'].to_f
          driver.gmaps = 1

          (@resp = {:status => :not_acceptable, :message => t('api.errors.driver_save')}) and
              return unless driver.save :validate => false

          if data['distance'] && data['request_id']
            request = Request.find data['request_id']
            request.params['distance'] = data['distance']
            request.save :validate => false
          end

          @resp = {:status => :ok}
        rescue Exception => e
          raise_exception e
        ensure
          render_resp false
        end
      }
    end
  end

  def trips
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless driver

          trip_id = nil

          Request.instant.where(:vehicle_id => driver.car.vehicle_id).order('created_at desc').all.each do |req|
            if DriverRequestHistory.where(:driver_id => driver.id, :request_id => req.id, :status => :decline).count == 0
              cur_step = req.broadcast_step
              max_distance = req.broadcast_distance_by_step cur_step
              calc_distance = ::Location.distance_between_coordinates(req.from_coord, driver.get_coordinates)
              trip_id = req.id if max_distance.blank? || calc_distance < max_distance
              break
            end
          end

          @resp = {:status => :ok}
          @resp[:trip_id] = trip_id if trip_id
          @resp
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  def trip_info
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless driver

          validate_trip data['request_id']
          return unless trip

          @resp = {:status => :ok}.merge trip.additional_info
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  def accept_trip
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless driver

          validate_trip data['request_id']
          return unless trip

          if trip.driver
            if trip.driver_id == driver.id
              @resp = {:status => :conflict, :message => t('api.errors.you_already_accept_trip')}
              return
            else
              @resp = {:status => :conflict, :message => t('api.errors.trip_already_accepted')}
              return
            end
          end

          (@resp = {:status => :precondition_failed, :message => t('api.errors.trip_wrong_status', :status => trip.status)}) and
              return unless Trip::Status::instant? trip

          (@resp = {:status => :precondition_failed, :message => t('api.errors.wrong_driver_status')}) and
              return if driver.status.to_sym != Chauffeur::Status::ACTIVE || Request::active_driver(driver.id).any?

          driver.status = Chauffeur::Status::ACCEPTED

          (@resp = {:status => :not_acceptable, :message => t('api.errors.driver_save', :errors => driver.errors.messages.to_s)}) and
              return unless driver.save :validate => false

          trip.driver = driver
          trip.car = driver.car
          trip.eta = Time.now + data['driver_eta'].to_i.minutes

          (@resp = {:status => :not_acceptable, :message => t('api.errors.trip_save', :errors => trip.errors.messages.to_s)}) and
              return unless trip.accepted! true
		
	  #ApnPushMessages.send 'REMREQ', trip
          send_apns_push_messages('REMREQ',trip)
	  trip.accepted_sms
          trip.accepted_email
          trip.notify_client :accepted, 'accept request'

          @resp = {:status => :ok}
        rescue Exception => e
          raise_exception e
        ensure
          render_resp 
        end
      }
    end
  end

  def decline_trip
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless driver

          validate_trip data['request_id']
          return unless trip

          #(@resp = {:status => :error, :message => t('api.errors.trip_wrong_status', :status => trip.status)}) and
          #    return unless Trip::Status::instant? trip

          history = DriverRequestHistory.create({
              :driver => driver,
              :request => trip,
              :status => :decline
          })

          trip.decline_email
          trip.decline_sms
          #trip.declined_sms

          (@resp = {:status => :not_acceptable, :message => t('api.errors.history_save', :errors => history.errors.messages.to_s)}) and
              return unless history

          @resp = {:status => :ok}
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  def driver_arrived
    respond_to do |format|
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless driver

          validate_trip data['request_id']
          return unless trip

          (@resp = {:status => :precondition_failed, :message => t('api.errors.trip_wrong_status', :status => trip.status)}) and
              return unless Trip::Status::accepted? trip

          driver.status = Chauffeur::Status::WAITING
          (@resp = {:status => :not_acceptable, :message => t('api.errors.driver_save', :errors => driver.errors.messages.to_s)}) and
              return unless driver.save :validate => false


          (@resp = {:status => :not_acceptable, :message => t('api.errors.trip_save', :errors => trip.errors.messages.to_s)}) and
              return unless trip.waiting!(true)

          trip.arrived_sms
          trip.arrived_email

          @resp = {:status => :ok}
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  def start_trip
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless driver

          validate_trip data['request_id']
          return unless trip

          (@resp = {:status => :precondition_failed, :message => t('api.errors.trip_wrong_status', :status => trip.status)}) and
              return unless Trip::Status.waiting?(trip) || Trip::Status.accepted?(trip)

          driver.status = Chauffeur::Status::BOOKED

          (@resp = {:status => :not_acceptable, :message => t('api.errors.driver_save', :errors => driver.errors.messages.to_s)}) and
              return unless driver.save :validate => false

          trip.picked_up_email
          trip.picked_up_sms

          trip.started_trip_sms

          trip.params['start_time'] = data['start_time'] if data['start_time']

           #@resp =  {:status => :error, :message => t('api.errors.trip_wrong_status', :status => trip.status)} and
           #  return unless (trip.accepted? || trip.waiting?)

          #trip.pre_payment
          (@resp = {:status => :not_acceptable, :message => t('api.errors.trip_save', :errors => trip.errors.messages.to_s)}) and
              return unless trip.started!(true)

          @resp = {:status => :ok}
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  def edit_trip
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless driver

          validate_trip data['request_id']
          return unless trip

          trip.params['addresses'] = data['intermediate addresses']
          trip.params['addresses'] ||= []
          trip.regenerate_distance if data['account_billed_credit_card']

          (@resp = {:status => :not_acceptable, :message => t('api.errors.trip_save', :errors => trip.errors.messages.to_s)}) and
              return unless trip.save :validate => false

          @resp = { :status => :ok, :estimated_cost => trip.rate, :coordinates => trip.coordinates }

        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  def reason_list
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless driver

          reasons = RequestCancelReason::select([:id, :comment]).all.collect {|reason| {:id => reason.id, :comment => reason.comment}} rescue nil
          reasons ||= []

          (@resp = {:status => :length_required, :message => t('api.errors.none_reasons')}) and
              return if reasons.empty?

          @resp = { :status => :ok, :reasons => reasons}
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  def cancel_trip
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless driver

          validate_trip data['request_id']
          return unless trip

	  #(@resp = {:status => :bad_request, :message => t('api.errors.invalid_driver')}) and
          (@resp = {:status => :bad_request, :message => "Invalid driver error because duid::#{driver.user_id} and trip.driver_id::#{trip.driver.driver_id} but (driver)user.id == #{user.id} so WTF?!"}) and
            return unless driver.user_id == trip.driver.user_id

          (@resp = {:status => :bad_request, :message => t('api.errors.invalid_reason_id')}) and
            return unless RequestCancelReason::where(:id => data['reason_id']).any?

          #@resp = {:status => :error, :message => t('api.errors.trip_wrong_status', :status => trip.status)} and
          #   return unless trip.accepted? || trip.instant? || Trip::status::started?

          trip.params['reason_id'] = data['reason_id']
          trip.cancelled_user_id = driver.user_id

          (@resp = {:status => :not_acceptable, :message => t('api.errors.trip_save', :errors => trip.errors.messages.to_s)}) and
              return unless trip.canceled!(true)

          driver.status = Chauffeur::Status::ACTIVE
          (@resp = {:status => :not_acceptable, :message => t('api.errors.driver_save', :errors => driver.errors.messages.to_s)}) and
              return unless driver.save :validate => false

          trip.cancel_email
          trip.cancel_sms

          trip.cancelled_sms

          @resp = {:status => :ok}
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  def drop_address
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless driver

          validate_trip data['request_id']
          return unless trip

          address = data['address']

          (@resp = {:status => :length_required, :message => t('api.errors.invalid_address')}) and
              return if address.blank?

          #trip.to.delete address
          #trip.params['to_coordinates'] ||= []
          #trip.params['to_coordinates'].delete_if { |item| item['name'].to_s == address.to_s }

          trip.to[0] =  address
          trip.params['to_coordinates'] ||= []
          trip.params['to_coordinates'][0] = {}
          trip.params['dropped_address'] ||= true

          (@resp = {:status => :not_acceptable, :message => t('api.errors.trip_save', :errors => trip.errors.messages.to_s)}) and
              return unless trip.save :validate => false

          @resp = {:status => :ok}
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  def finish_trip
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless driver
          validate_trip data['request_id']
          return unless trip

          (@resp = {:status => :precondition_failed, :message => t('api.errors.trip_wrong_status', :status => trip.status)}) and
              return unless Trip::Status.started? trip

          trip.real_time = data['duration'] if data['duration'].to_f > 0
          trip.real_distance = data['distance'] if data['distance'].to_f > 0

          (@resp = {:status => :not_acceptable, :message => t('api.errors.trip_save', :errors => trip.errors.messages.to_s)}) and
              return unless trip.finished!(true)

          #(@resp = {:status => :error, :message => t('api.errors.payment', :errors => trip.errors.messages.to_s)}) and
          #    return unless trip.apply_pay

          #trip.apply_pay

          driver.status = Chauffeur::Status::ACTIVE
          (@resp = {:status => :not_acceptable, :message => t('api.errors.driver_save', :errors => driver.errors.messages.to_s)}) and
              return unless driver.save :validate => false

          trip.finished_email
          trip.finished_sms

          #trip.finished_trip_sms

          @resp = {:status => :ok}
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  def gratuity
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless driver
          validate_trip data['request_id']
          return unless trip

          amount = data['amount']
          (@resp = {:status => :expectation_failed, :message => t('api.errors.invalid_gratuity')}) and
              return if amount.to_f <= 0

          (@resp = {:status => :precondition_failed, :message => t('api.errors.trip_wrong_status', :status => trip.status)}) and
              return unless Trip::Status.started? trip

          trip.transaction.spec_gratuity = amount
          (@resp = {:status => :not_acceptable, :message => t('api.errors.transaction_save', :errors => transaction.errors.messages.to_s)}) and
              return unless trip.transaction.save :validate => false

          (@resp = {:status => :internal_server_error, :message => 'Error while sending gratuity sms'}) and
              return unless trip.gratuity_sms

          @resp = {:status => :ok}
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  def admin_message_response
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless driver

          #(@resp = { :status => :error, :message => 'Invalid notification' }) and
          #  return unless Notification::where(:internal_name => data['message']).any?

          (@resp = { :status => :bad_request, :message => 'Invalid from number' }) and
            return if data['from'] && !User::where(:id => data['from']).any?

          notifications = []

          users = data['from'] ? User.where(:id => data['from']) : User.find_all_by_role_id(Role.admin.id)
          notification = {
              :params => {
                  :driver => driver.full_name,
                  :driver_id => driver.id,
                  :time => Time.now.strftime(HelperTools::JS_DATE)
              }
          }
          Notification::where(:internal_name => data['message']).any? ?
              notification[:notification] = Notification::find_by_internal_name(data['message']) :
              notification[:text_field] = "<span class=\"datetime\" data-date=\"#{Time.now.strftime(HelperTools::JS_DATE)}\"></span>: #{driver.full_name} -\"#{data['message']}\""

          users.each do |user|
            notifications << notification.merge({:user_id => user.id})
          end

          NotificationPull.create notifications
          @resp = { :status => :ok }
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  private
  # @return [Driver]
  def validate(data)

    (@resp = {:status => :bad_request, :message => t('api.errors.invalid_request')}) and return unless data
    (@resp = {:status => :unauthorized, :message => t('api.errors.incorrect_token')}) and return unless User::where(:api_token => data['token']).any?

    @user = User::find_by_api_token data['token']

    #(@resp = {:status => :error, :message => t('api.errors.expired_token')}) and return if @user.token_expire && Time.now > @user.token_expire
    (@resp = {:status => :forbidden, :message => t('api.errors.access_denied')}) and return unless @user.role?(:driver)

    @driver = Driver::find_by_user_id user.id
    (@resp = {:status => :bad_request, :message => t('api.errors.no_driver')}) and return unless @driver

    @driver.last_access = Time.now
    @driver.online = 1
    @driver
  end

  # @return [Request]
  def validate_trip(data)
    (@resp = {:status => :bad_request, :message => t('api.errors.none_exist_trip')}) and
        return false unless Request::where(:id => data).any?

    @trip = Request::find data
  end

  # @param [Exception] e
  def raise_exception(e)
    @resp = {:status => e.to_s, :message => e.to_s, :backtrace => e.backtrace.to_json}
    log_exception e
  end

  def render_resp(history = true)
    @resp ||= {:status => :internal_server_error, :message => 'some error'}

    if history
      data        = {
          :action    => params[:action],
          :user_type => :driver,
          :date      => Time.now,
          :request   => params.to_json,
          :response  => @resp.to_json
      }
      data[:user] = @user if @user

      if @driver
        data[:device_id]     = @driver.device_id
        data[:device_system] = @driver.device
      end

      ClientActivityHistory::create(data)
    end
    render json: @resp , status: @resp[:status]
  end

  #@return [Driver]
  def driver
    @driver
  end

  #@return [Request]
  def trip
    @trip
  end

  #@return [User]
  def user
    @user
  end

  def send_apns_push_messages(type,trip)
    require 'uri'
    require 'net/https'
    Thread.new do
      params = {
        :ios => {
          :alert => {
            :body => 'Remove Request',
            :data => {
	      :rt => type,
	      :ln => 0.0,
	      :lt => trip.from_coord['lng'],
              :rq => trip.id
            }
          }
        }
      }

      uri = URI.parse('https://pushtech.services.test.cc/send')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})
      request.body = params.to_json

      response = http.request(request)
      response
    end
  end

end

