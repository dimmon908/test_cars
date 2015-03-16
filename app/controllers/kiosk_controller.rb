class KioskController < ApplicationController

  def prepare_request
    begin
      pickup = params[:pickup]
      destination = params[:destination]
      suite = params[:suite]
      promo = params[:promo]

      vehicle_id = params[:vehicle_id]
      distance = params[:distance]
      time = params[:time]

      req_params = JSON.parse params[:params]

      phone = params[:phone]
      email = params[:email]
      first_name = params[:first_name]
      last_name = params[:last_name]

      cond = Classes::KioskUser.where(:phone => phone, :email => email)
      user = nil
      user = cond.first if cond.any?

      render_error('Such user already registered. Please login.') and return if user && user.show

      if user.nil?
        user = Classes::KioskUser.new
        user.email = email
        user.username = email
        user.phone = phone
        user.first_name = first_name
        user.last_name = last_name
        user.show = false
        user.need_validate = false
        user.password = Configurations[:default_kiosk_user_password].to_s
        user.password_confirmation = Configurations[:default_kiosk_user_password].to_s
        user.payment = Payment::Type::KIOSK_SWIPER

        render_error(user.errors.messages.to_s) and return unless user.valid?
      end

      request = Request.new({
        :user => user,
        :distance => distance,
        :time => time,
        :status => Trip::Status::INSTANT,
        :date => '',
        :from => pickup,
        :to => [destination],
        :vehicle_id => vehicle_id,
        :params => req_params,
        :promo => promo,
        :recommended_room => suite,
        :comment => '',
        :payment => Payment::Type::KIOSK_SWIPER
                            })

      request.user = user
      request.from = pickup
      request.to = [destination]
      request.status = Trip::Status::INSTANT

      if request.valid?
        set_resp :status => :ok, :rate => request.calculate_rate
      else
        set_resp :status => :error, :message => request.errors.messages
      end

    rescue Exception => e
      set_exception e
    ensure
      render_resp
    end
  end


  def create_request
    begin
      pickup = params[:pickup]
      destination = params[:destination]
      suite = params[:suite]
      promo = params[:promo]

      vehicle_id = params[:vehicle_id]
      distance = params[:distance]
      time = params[:time]

      req_params = JSON.parse params[:params]

      phone = params[:phone]
      email = params[:email]
      first_name = params[:first_name]
      last_name = params[:last_name]

      cond = Classes::KioskUser.where(:phone => phone, :email => email)
      user = nil
      user = cond.first if cond.any?
      render_error('Such user already registered. Please login.') and return if user && user.show

      if user.nil?
        user = Classes::KioskUser.new
        user.email = email
        user.username = email
        user.phone = phone
        user.first_name = first_name
        user.last_name = last_name
        user.show = false
        user.need_validate = false
        user.password = Configurations[:default_kiosk_user_password].to_s
        user.password_confirmation = Configurations[:default_kiosk_user_password].to_s
        user.payment = Payment::Type::KIOSK_SWIPER

        render_error(user.errors.messages.to_s) and return unless user.save
      end

      request = Request.new({
        :user_id => user.id,
        :distance => distance,
        :time => time,
        :status => Trip::Status::INSTANT,
        :date => '',
        :from => pickup,
        :to => [destination],
        :vehicle_id => vehicle_id,
        :params => req_params,
        :promo => promo,
        :recommended_room => suite,
        :comment => '',
        :payment => Payment::Type::KIOSK_SWIPER
                            })

      request.user = user
      request.from = pickup
      request.to = [destination]
      request.status = Trip::Status::INSTANT

      if request.save
        set_resp :status => :ok, :trip_id => request.id, :user_id => user.id, :rate => request.rate
      else
        set_resp :status => :error, :message => request.errors.messages
      end

    rescue Exception => e
      set_exception e
    ensure
      render_resp
    end
  end

  def add_card
    begin
      postal_code = params[:postal]

      user = Classes::KioskUser.find params[:user_id]

      swipe_card_data = JSON.parse params[:swipe_card]

      user.swipe_card = SwipeCard.create(swipe_card_data.merge({:partner => user})) if user.swipe_card.nil? || user.swipe_card.track_1 != swipe_card_data['track_1']

      user.postal_code = postal_code
      user.password = ''

      if user.save
        set_resp  :status => :ok, :card_id => user.swipe_card.id
      else
        set_resp :status => :error, :message => user.errors.messages
      end

    rescue Exception => e
      set_exception e
    ensure
      render_resp
    end
  end

  def trip_auth
    begin
      trip = Request.find params[:trip_id]
      result = false

      Request.transaction do
        if trip.pre_payment
          result = true
        else
          raise ActiveRecord::Rollback, ''
        end
      end

      if result
        trip.confirm
        set_resp :status => :ok
      else
        set_resp :status => :error, :message => trip.errors.messages[:payment]
      end

    rescue Exception => e
      set_exception e
    ensure
      render_resp
    end
  end

  def trip_auth_test
    begin
      Request.find(params[:trip_id]).confirm
      set_resp :status => :ok
    rescue Exception => e
      set_exception e
    ensure
      render_resp
    end
  end

  def trip_info
    begin
      trip = Request.find params[:trip_id]
      set_resp ({:status => :ok}.merge trip.additional_info)
    rescue Exception => e
      set_exception e
    ensure
      render_resp
    end
  end

  def check_driver
    begin
      trip = Request.find params[:trip_id]

      set_resp({:status => :ok, :trip_status => trip.status}) and return if Trip::Status.canceled? trip

      if trip.driver
        driver = trip.driver
        set_resp  :status => :ok,
                  :driver_id => trip.driver.id,
                  :driver => driver.basic_info,
                  :car => driver.car.to_js,
                  :trip_status => trip.status
      else
        set_resp :status => :error
      end
    rescue Exception => e
      set_exception e
    ensure
      render_resp
    end
  end

  def driver_info
    begin
      driver = Driver.find params[:driver_id]
      set_resp({:status => :ok}.merge({:driver => driver.basic_info}).merge({:car => driver.car.to_js}))
    rescue Exception => e
      set_exception e
    ensure
      render_resp
    end
  end


  private
  def set_resp(data = {})
    @resp ||= {}
    @resp.merge! data
  end

  # @param [Exception] e
  def set_exception(e)
    set_resp :status => :error, :message => e.message, :backtrace => e.backtrace.to_json
  end

  # @param [Exception] e
  def raise_exception(e)
    set_exception e
    log_exception e
  end

  def render_error(message)
    set_resp :status => :error, :message => message
  end

  def render_resp
    set_resp :status => :error, :message => 'some error' if @resp.nil?
    render json: @resp
  end

end
