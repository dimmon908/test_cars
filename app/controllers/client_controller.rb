class ClientController < ApplicationController
  def initialize
    @resp = nil
    @user = nil
    @vehicle = nil
    @trip = nil
  end

  # Sign Up
  def new
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          (@resp = {:status => :error, :message => t('api.errors.invalid_request')}) and return unless data
          (@resp = {:status => :error, :message => t('api.errors.empty_email')}) and return if data['email'].to_s == ''
          (@resp = {:status => :error, :message => t('api.errors.unique_email')}) and return if User::where(:email => data['email']).any?
          (@resp = {:status => :error, :message => t('api.errors.empty_phone')}) and return if data['phone_number'].to_s == ''
          (@resp = {:status => :error, :message => t('api.errors.unique_phone')}) and return if User::where(:phone => data['phone_number']).any?
          (@resp = {:status => :error, :message => t('api.errors.empty_password')}) and return if data['password'].to_s == ''

          @user = Classes::PersonalAccount.new({
              :email => data['email'],
              :phone => data['phone_number'],
              :password => data['password'],
              :first_name => data['first_name'],
              :last_name => data['last_name']
          })
          (@resp = {:status => :error, :message => t('api.errors.history_save', :errors => user.errors.messages.to_s)}) and return unless @user.save :validate => false
          @resp = {:status => :ok}
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  def register
    begin
      data = params[:data]
      (@resp = {:status => :error, :message => t('api.errors.invalid_request')}) and return unless data
      (@resp = {:status => :error, :message => t('api.errors.empty_email')}) and return if data['email'].to_s == ''
      (@resp = {:status => :error, :message => t('api.errors.unique_email')}) and return if User::where(:email => data['email']).any?
      (@resp = {:status => :error, :message => t('api.errors.empty_phone')}) and return if data['phone_number'].to_s == ''
      (@resp = {:status => :error, :message => t('api.errors.unique_phone')}) and return if User::where(:phone => data['phone_number']).any?
      (@resp = {:status => :error, :message => t('api.errors.empty_password')}) and return if data['password'].to_s == ''

      @user = Classes::PersonalAccount.new({
                                               :email => data['email'],
                                               :phone => data['phone_number'],
                                               :password => data['password'],
                                               :first_name => data['first_name'],
                                               :last_name => data['last_name']
                                           })
      (@resp = {:status => :error, :message => t('api.errors.history_save', :errors => user.errors.messages.to_s)}) and return unless @user.save :validate => false
      @resp = {:status => :ok, :user_id => @user.id }
    rescue Exception => e
      raise_exception e
    ensure
      render_resp
    end
  end

  # card/update
  def update_credit_card
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless user

          (@resp = {:status => :error, :message => t('api.errors.none_cars')}) and return if Card.where(:id => data['id']).any?
          card = Card.find data['id']
          card.update_attributes({
            :card_number => data['number'],
            :card_expire => (DateTime::strptime(data['expire_date'], '%m/%Y') rescue ''),
            :owner => data['name_on_the_card'],
            :cvv => data['cvv'],
            :postal_code => data['postal']
          })


          if card.save
            @resp = {:status => :ok}
          else
            @resp = {:status => :error, :message => card.errors.messages.to_s}
          end
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  # card/add
  def add_credit_card
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless user

          card = Card.new({
              :user_id => user.partner_id,
              :user => user,
              :card_number => data['number'],
              :card_expire => DateTime::strptime(data['expire_date'], '%m/%Y'),
              :owner => data['name_on_the_card'],
              :postal_code => data['postal_code'],
              :cvv => data['cvv']
          })

          if card.save
            @resp = {:status => :ok, :card_id => card.id }
            user.card_id = card.id and user.save :validate => false unless user.card_id
          else
            @resp = {:status => :error, :message => card.errors.messages.to_s}
          end
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  def set_photo
    begin
      #Log << {data: params}.to_s
      @user = User.find params[:id] if User.where(:id => params[:id]).any?
      return unless user

      @resp = {:status => :error, :message => 'none photo field'} unless params[:photo]
      user.photo = params[:photo]

      if user.save :validate => false
        @resp = {:status => :ok, :photo => user.user_profile.photo.url(:small) }
      else
        @resp = {:status => :error, :message => user.errors.messages.to_s}
      end
    rescue Exception => e
      raise_exception e
    ensure
      render_resp
    end
  end

  def location
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless user

          (@resp = {:status => :error, :message => t('api.errors.invalid_request')}) and
              return unless data['latitude'] && data['longitude']

          user.params[:latitude] = data['latitude'].to_f
          user.params[:longitude] = data['longitude'].to_f

          (@resp = {:status => :error, :message => t('api.errors.driver_save')}) and
              return unless user.save :validate => false
          @resp = {:status => :ok}
        rescue Exception => e
          raise_exception e
        ensure
          render_resp false
        end
      }
    end
  end

  # car/types
  def car_types
    respond_to do |format|
      format.html {}
      format.json {
        data = JSON::parse params[:data]
        begin
          validate data
          return unless user

          types = Vehicle.all.collect {|v|
            {
                :id => v.id,
                :photo => v.photo,
                :name => v.name,
                :description => v.desc,
                :rate => v.rate,
                :passengers => v.passengers
            }
          }
          @resp = {:status => :ok, :types => types}
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  # car/locations
  def car_locations
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless user

          radius = data['radius']
          location = {:lat => data['lat'], :lng => data['lng']}

          if data['car_type_id']
            drivers = Driver::where('online = ? AND status = ? AND car_id IN (?)',
                                    1,
                                    Chauffeur::Status::ACTIVE,
                                    Car::select(:id).where(:vehicle_id => data['car_type_id']).collect {|c| c.id}).all
          else
            drivers = Driver::available.all
          end

          @resp = {:status => :ok, :cars => drivers.collect { |d| d.to_js } }
        rescue Exception => e
          raise_exception e
        ensure
          render_resp false
        end
      }
    end
  end

  def estimated
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless user

          validate_vehicle data
          return unless vehicle

          pickup = data['pickup_address']
          dest = data['destination_address']

          (@resp = {:status => :ok, :estimated => 0}) and return if dest.blank?

          distance, time = Location::distance(pickup, dest)
          estimated = Fares::calculate(distance, time, vehicle.rate, vehicle)

          @resp = {:status => :ok, :estimated => estimated}
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  def start_request
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless user

          validate_vehicle data
          return unless vehicle

          pickup = data['pickup_address']
          dest = data['destination_address']

          if dest
            distance, time = Location::distance(pickup, dest)
          else
            distance, time = 0, 0
          end

          if data['request_date']
            date = DateTime::strptime(data['request_date'], Request::TIME_STAMP_FORMAT)
            status = :future
          else
            date = Time.now
            status = :instant
          end

          request = Request.new({
              :user_id => user.id,
              :vehicle_id => vehicle.id,
              :status => status,
              :from => pickup,
              :to => [dest],
              :distance => distance,
              :time => time,
              :date => date
          })

          if request.save
            request.confirm
            @resp = {:status => :ok, :request_id => request.id}
          else
            @resp = {:status => :error, :message => request.errors.messages.to_s}
          end

        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  def cancel_request
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless user

          validate_trip data
          return unless trip

          render json: {:status => :error, :message => trip.errors.messages} and return unless trip.client_canceled! user.id

          @resp = {:status => :ok, :request_id => trip.id, :passed_no_fee_time => trip.before_cancel_time <= 0}
          ApnPushMessages.send 'KILREQ', trip
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  def add_favorite
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless user

          address = data['address']
          geocode = Location::geocode(address)
          geocode = geocode['results'][0]
          google_address = GoogleAddress.new geocode['address_components'], geocode['name']

          favorite = Favorites::new({
            :user_id => user.id,
            :address => address,
            :latitude => geocode['geometry']['location']['lat'],
            :longitude => geocode['geometry']['location']['lng'],
            :enabled => 1,
            :street => google_address.street,
            :city => google_address.city,
            :name => google_address.name,
            :additional => MessagePack::pack(geocode)
          })

          if favorite.save
            @resp = {:status => :ok}
          else
            @resp = {:status => :error, :message => favorite.errors.messages.to_s}
          end
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  def favorites
    respond_to do |format|
      format.html {}
      format.json {
        begin
          data = JSON::parse params[:data]
          validate data
          return unless user

          favorites = Favorites::where(:user_id => user.id).all.collect { |f|
            {
              :id => f.id,
              :name => f.name,
              :address => f.address,
              :lat => f.latitude,
              :lng => f.longitude,
              :city => f.city,
              :street => f.street
            }
          }
          @resp = {:status => :ok, :favorites => favorites}
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end
  end

  private
  # @return [User]
  def validate(data)

    (@resp = {:status => :error, :message => t('api.errors.invalid_request')}) and
        return unless data

    (@resp = {:status => :error, :message => t('api.errors.incorrect_token')}) and
      return unless User::where(:api_token => data['token']).any?

    @user = User::find_by_api_token data['token']
    (@resp = {:status => :error, :message => t('api.errors.expired_token')}) if @user.token_expire && Time.now > @user.token_expire
  end

  # @return [Vehicle]
  def validate_vehicle(data)
    (@resp = {:status => :error, message: t('api.errors.invalid_vehicle_id')}) and
        return unless Vehicle::where(:id => data['selected_car_type_id']).any?
    @vehicle = Vehicle::find data['selected_car_type_id']
  end

  def validate_trip(data)
    (@resp = {:status => :error, :message => t('api.errors.invalid_trip_id')}) and
        return unless Request::where(:id => data['request_id'])
    @trip = Request::find data['request_id']
  end

  # @param [Exception] e
  def raise_exception(e)
    @resp = {:status => :error, :message => e.to_s, :backtrace => e.backtrace.to_json}
    Rails.logger.fatal "params = \n#{params}"
    log_exception e
  end

  def render_resp(need_log = true)
    @resp ||= {:status => :error, :message => 'some error'}

    data = {
        :action    => params[:action],
        :user_type => :client,
        :date      => Time.now,
        :request   => params.to_json,
        :response  => @resp.to_json
    }

    if user
      data[:user]          = user
      data[:device_id]     = user.profile.device_id
      data[:device_system] = user.profile.device
    end

    ClientActivityHistory::create(data) if need_log
    render json: @resp
  end

  #@return [Vehicle]
  def vehicle
    @vehicle
  end
  #@return [User]
  def user
    @user
  end
  #@return [Request]
  def trip
    @trip
  end
end