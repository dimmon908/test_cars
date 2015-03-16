#encoding: utf-8
class RequestController < ApplicationController
  before_filter :authenticate_user!, :except => [:create_request, :mock_create_request, :active_request_status, :cancel, :estimate_rate, :last_five, :notify, :next_future]
  set_tab :request
  respond_to :js, :html, :json

  def show
    begin
      trip = Request::find params[:id] rescue nil
      render json: {:status => :error, :message => 'none exist'} and return unless trip
      render json: {:status => :ok, :coordinates => trip.coordinates, :add_info => trip.add_info}
    rescue Exception => e
      log_exception e
      render json: {:status => :error, :messages => e.to_s, :backtrace => e.backtrace.to_s}
    end
  end

  #GET
  def index
    redirect_to '/logout' and return unless can? :request, :create

    @list = Favorites::where(:user_id => current_user.id).order('created_at DESC').limit(Configurations[:last_address].to_i)

    from_session

    respond_with self.resource
  end

  #POST
  def create
    begin
      rebuild_params
      build_resource(params[resource_name])

      if Trip::Status::instant?(resource) &&
          !resource.recommend? &&
          !can?(:multiple_instant, current_user) &&
          Request::where(:user_id => current_user.id).active.any?
        resource.errors[:status] << 'No more than One current order for individual user, unless requested for a friend.'
        render :json => {:status => :error, :messages => resource.errors.messages.to_json}
        return
      end

      if resource.valid?
        save_to_session
        render :json => {:status => :ok, :id => resource.id}
      else
        render :json => {:status => :error, :messages => resource.errors.messages.to_json}
      end
    rescue Exception => e
      log_exception e
      render :json => {:status => :error, :messages => e.to_s}
    end
  end

  def estimate_rate
    vehicle = Vehicle.find params[:vehicle_id]
    rate = Fares::calculate(params[:distance], params[:time], vehicle.rate, vehicle)
    rate = PromoCode.calc_discount(params[:promo_code], params[:user_id], rate) unless params[:promo_code].blank?
    rate = 0 if rate < 0

    render :json => {:rate => rate, :min => Configurations[:minimum_fare].to_f}
  end

  def mock_create_request
    @params = {Request: {
        user_id:    6,
        distance:   143256,
        time:       5470,
        status:     'instant',
        date:       '1/6/2014 - 03:30 PM',
        from:       '46560 Fremont Blvd Fremont, CA',
        vehicle_id: 1,
        params:     {
            from_coordinates: {
                lat:  37.482989,
                lng:  -121.945121,
                city: 'Fremont',
                name: 'Fremont'
            },
            to_coordinates:   {
                lat:  37.444182,
                lng:  -121.876459,
                city: 'Milpitas',
                name: 'Milpitas'
            }
        },
        to:         ['480 Bayview Park Dr Milpitas, CA']
    }
    }

    current_user = User.find(@params[:Request][:user_id])
    rebuild_params
    build_resource(@params[:Request])

    if resource.instant? &&
        !resource.recommend? &&
        !can?(:multiple_instant, current_user) &&
        Request::where('`user_id` = ? and `status` IN (?)', current_user.id, Request::ACTIVE).any?
      resource.errors[:status] << 'No more than One current order for individual user, unless requested for a friend.'
      render :json => {:status => :error, :messages => resource.errors.messages.to_json}
      return
    end

    if resource.save
      # save_to_session

      # book
      if params[resource_name] && params[resource_name][:params] && params[resource_name][:params]['notification']
        notification = params[resource_name][:params][:notification]
        notification.delete :__i__
        self.resource.params['notification'] = notification
      end

      if self.resource.save
        #book confirm
        resource.confirm
        # send_apns_push_messages resource\
        # ApnPushMessages.send nil, resource
      end
    else
      render :json => {:status => :error, :messages => resource.errors.messages.to_json}
    end

  end

  def create_request
    @kparams = params[:Request][:paytoken]
    current_user = User.find(params[:Request][:user_id])
    rebuild_params
    build_resource(params[resource_name])

    if resource.instant? &&
        !resource.recommend? &&
        !can?(:multiple_instant, current_user) &&
        Request::where('`user_id` = ? and `status` IN (?)', current_user.id, Request::ACTIVE).any?
      resource.errors[:status] << 'No more than One current order for individual user, unless requested for a friend.'
      render :json => {:status => :error, :messages => resource.errors.messages.to_json}
      return
    end

    resource.payment = current_user.payment if current_user.net_terms?
    result = false
    resource_class.transaction do
      if resource.save && resource.pre_payment
        result = true
      else
        raise ActiveRecord::Rollback, ''
      end
    end


    if result
      resource.confirm
      # send_apns_push_messages resource
	 ApnPushMessages.send 'NEWREQ', resource, @kparams
      render :json => {:status => :ok, :id => resource.id}
    else
      render :json => {:status => :error, :messages => resource.errors.messages.to_json}
    end
  end

  def get_create_request
    begin
      data = JSON.parse '{"Request":{"comment":"","date":"2014-03-20 17:22:20 +0000","distance":"3162","from":"46554-46606 Fremont Boulevard, Fremont, CA 94538, USA","params":{"from_coordinates":{"city":"","lat":"37.4819512326674","lng":"-121.9451112115028","name":"46560 Fremont Blvd"},"to_coordinates_0":{"city":"","lat":"37.50859972011734","lng":"-121.9498419268341","name":"44063 Fremont Blvd"},"passengers":[{"0":{}}]},"status":"future","time":"264","to":"44053 Fremont Boulevard, Fremont, CA 94538, USA","user_id":"19","vehicle_id":"1"}}'
      current_user = User.find(data['Request']['user_id'])

      rebuild_params
      build_resource(data['Request'])

      if resource.instant? &&
          !resource.recommend? &&
          !can?(:multiple_instant, current_user) &&
          Request::where('`user_id` = ? and `status` IN (?)', current_user.id, Request::ACTIVE).any?
        resource.errors[:status] << 'No more than One current order for individual user, unless requested for a friend.'
        render :json => {:status => :error, :messages => resource.errors.messages.to_json}
        return
      end

      resource.payment = current_user.payment if current_user.net_terms?

      result = false
      resource_class.transaction do
        if resource.save && resource.pre_payment
          result = true
        else
          raise ActiveRecord::Rollback, ''
        end
      end


      if result
        resource.confirm
        # send_apns_push_messages resource
        # ApnPushMessages.send nil, resource
        render :json => {:status => :ok, :id => resource.id}
      else
        render :json => {:status => :error, :messages => resource.errors.messages.to_json}
      end

    rescue Exception => e
      render json: {:status => :error, :message => e.message}
    end
  end

  def confirm
    from_session false
    unless self.resource
      build_resource
      self.resource.errors[:main] << I18n.t('general.error')
      render :template => 'request/_new', :layout => false
      return
    end
    render :template => 'request/_confirm', :layout => false
  end

  #GET
  def new
    from_session
    render :template => 'request/_new', :layout => false
  end

  def edit

  end

  def book_edit
    rebuild_params
    from_session false
    unless self.resource
      build_resource({})
      self.resource.errors << I18n.t('general.error')
      render :template => 'request/_new', :layout => false
      return
    end
    render :template => 'request/_new', :layout => false
  end

  def update
    build_resource(params[resource_name])
    resource.params = params[:params]
    if resource.save
      render :json => {:status => :ok, :id => resource.id}
    else
      render :json => {:status => :error, :messages => resource.errors.messages}
    end
  end

  def book_update
    rebuild_params
    self.resource      = resource_class.find params[:id]
    self.resource.rate = 0
    if self.resource.update_attributes(params[resource_name])
      render :json => {:status => :ok, :id => resource.id}
    else
      render :json => {:status => :error, :messages => resource.errors.messages}
    end
  end

  def book
    from_session

    if params[resource_name] && params[resource_name][:params] && params[resource_name][:params]['notification']
      notification = params[resource_name][:params][:notification]
      notification.delete :__i__
      self.resource.params['notification'] = notification
    end

    result = false
    resource_class.transaction do
      if resource.save && resource.pre_payment
        result = true
      else
        raise ActiveRecord::Rollback, ''
      end
    end

    if result
      # send_apns_push_messages('NEWREQ',resource)
      ApnPushMessages.send 'NEWREQ', resource
      session[resource_name] = resource.id
      resource.confirm
      render :json => {:status => :ok, :id => resource.id}
    else
      render :json => {:status => :error, :messages => resource.errors.messages, :id => resource.id}
    end
  end

  def book_confirm
    self.resource = resource_class.find(session[resource_name])
    unless self.resource
      build_resource({})
      self.resource.errors << I18n.t('general.error')
      render :template => 'request/_new', :layout => false
      return
    end
    clear_session

    render :template => 'request/_result', :layout => false
  end

  def cancel

    render json: {:status => :error, :message => 'Invalid number', :params => request} and return unless Request::where(:id => params[:id]).any?

    trip = Request::find params[:id]

    user_id = trip.user_id
    user_id = current_user.id if current_user

    render json: {:status => :error, :message => trip.errors.messages, :params => request} and return unless  trip.client_canceled! user_id
    render json: {:status => :ok}
    #send_apns_push_messages('KILREQ',trip)
    ApnPushMessages.send 'KILREQ', trip
  end

  def active_list
    begin
      if can? :admin, :all
        rel        = Request.active_list
        future_rel = Request.future
      else
        rel        = Request.by_partner(current_user.partner_id).active_list
        future_rel = Request.by_partner(current_user.partner_id).future
      end

      render nothing: true, :status => 404 and return if rel.count < 1 && future_rel.count < 1

      @tab = :active
      if can? :multiple_instant, current_user
        @list = rel.order('created_at DESC').all
      else
        @list = rel.order('created_at DESC').all
        #@list = rel.order('created_at DESC').limit(1).all
      end

      @future_list = future_rel.order('created_at DESC').all

    rescue Exception => e
      log_exception e
      nil
    end

    @selected = params[:id]
    @list     ||= []

    render :template => 'request/_active_list', :layout => false
  end

  def active_request_status
    #rel = Request::where('status IN (?) OR (status IN (?) AND date > ? and id = ?)', Request::ACTIVE, Request::PAST, Time.now.beginning_of_day, params[:id])
    rel = Request::where('id = ?', params[:id])
    #future_rel = Request::where('status = ? ', :future)

    render nothing: true, :status => 404 and return if rel.count < 1 #&& future_rel.count < 1

    #if can? :multiple_instant, current_user
    #  @list = rel.order('created_at DESC').all
    #else
    #  @list = rel.order('created_at DESC').limit(1).all
    #end

    first = rel.first

    selected_driver = ''
    selected_driver = Driver.find first.driver_id if first.driver_id

    selected_vehicle = ''
    selected_vehicle = Vehicle.find first.vehicle_id if first.vehicle_id

    selected_car = ''
    selected_car = selected_driver.car unless selected_driver.blank?

    render json: {
        :request => first,
        :driver => selected_driver,
        :vehicle => selected_vehicle,
        :car => selected_car
    }
  end

  def past_list
    @from_date = DateTime.strptime(params[:from_date].to_s, Request::DATE_FORMAT) rescue nil
    @to_date = DateTime.strptime(params[:to_date].to_s, Request::DATE_FORMAT) rescue nil

    @from_date ||= Time.now.at_beginning_of_month
    @to_date   ||= Time.now

    @tab = :past

    rel = Request
    rel = rel.by_user(current_user.partner_id) unless can? :admin, :all
    rel = rel.past.dates(@from_date, @to_date)

    rel = rel.limit(30) if current_user.developer?

    @list = rel.order('`created_at` DESC').all rescue nil
    @list ||= []

    if params[:from_date] || params[:to_date]
      render :template => 'request/_list', :layout =>  false
    else
      render :template => 'request/_past_list', :layout =>  false
    end
  end

  def last_five
    last_five = Request.by_user(params[:id]).order('date desc').limit(5)
    render json: last_five
  end

  def next_future
    futures = Request.by_user(params[:id]).future.order("date desc")
    render json: futures
  end

  def favorites_list
    @list     = Favorites::where(:user_id => current_user.partner_id).order('created_at DESC').limit(Configurations[:last_address].to_i)
    @selected = params[:selected]
    render template: 'address_book/_list', :layout => false
  end

  def in_favorites
    address = params[:address]
    render json: {status: :error} and return if address.blank?

    favorite = Favorites::where(:user_id => current_user.id, :address => address).any?
    render json: {status: :error} and return if favorite

    render json: {status: :ok}
  end

  def add_favorites
    begin
      Favorites::create({
                            :address   => params[:address],
                            :user_id   => current_user.id,
                            :city      => params[:city],
                            :street    => params[:street],
                            :latitude  => params[:lat],
                            :longitude => params[:lng],
                            :name      => params[:name],
                            :enabled   => 1
                        }) unless Favorites::where(:address => params[:address], :user_id => current_user.id).any?

      render json: {status: :ok}
    rescue Exception => e
      log_exception e
      render json: {status: :error, :message => e.to_s, :backtrace => e.backtrace.to_s}
    end
  end

  def remove_favorites
    begin
      render json: {
          :status  => :error,
          :message => t('messages.no_rights'),
          :params => request
      } and return unless Favorites::where(:id => params[:id], :user_id => current_user.id).any?

      Favorites::delete(params[:id])
      render json: {status: :ok}
    rescue Exception => e
      log_exception e
      render json: {status: :error, :message => e.to_s, :backtrace => e.backtrace.to_s}
    end
  end

  def payment
    begin
      request2 = Request::find params[:id]
      request2.authorize_payment
      render json: {:status => :ok}
    rescue Exception => e
      log_exception e
      render json: {:status => :error, :message => e.to_s, :backtrace => e.backtrace.to_s}
    end
  end

  def notify
    begin
      render json: {status: :error, :message => 'No request', :params => request} and return unless resource_class::where(:id => params[:id]).any?

      notify = params[:data]
      notify = notify.is_a?(Hash) ? notify : Hash(notify)
      notify ||= []

      resource                  = resource_class::find params[:id]
      resource.params['notify'] = notify
      resource.save :validate => false

      resource.created_sms

      render json: {:status => :ok}
    rescue Exception => e
      log_exception e
      render json: {status: :error, :message => e.to_s, :params => request}
    end
  end

  def before_cancel_time
    render json: {:status => :error, :message => 'Invalid request', :params => request} and return unless Request::where(:id => params[:id]).any?

    time = Request.find(params[:id]).before_cancel_time
    render json: {:status => :error, :message => 'Not booked yet', :params => request} and return unless time

    render json: {:status => :ok, :time => time.to_i}
  end

  def resource=(new_resource)
    instance_variable_set(:"@#{resource_name}", new_resource)
  end

  # @return [Request]
  def resource
    instance_variable_get(:"@#{resource_name}")
  end



  private
  def build_resource(hash=nil)
    hash                  ||= {}
    #hash['date'] = HelperTools::datetime(hash['date']) if hash['date'].to_s =~ Request::TIME_STAMP_REGEXP
    self.resource         = resource_class.new(hash)
    self.resource.user_id ||= current_user.id
    self.resource.payment ||= current_user.payment
  end

  def rebuild_params
    return unless params[resource_name]
    params[resource_name]['date'] = HelperTools::datetime(params[resource_name]['date']) if params[resource_name]['date'].to_s =~ Request::TIME_STAMP_REGEXP
    return unless params[resource_name]['params']
    params[resource_name]['params']['passengers'].delete '__id__' rescue nil
    params[resource_name]['params']['notification'].delete '__i__' rescue nil
  end

  def resource_name
    'Request'
  end

  # @return Request
  def resource_class
    Request
  end

  def save_to_session
    session[resource_name] = params[resource_name].to_hash
  end

  def from_session(build = true)
    if session[resource_name]
      begin
        build_resource(session[resource_name])
        resource.alt_handle
      rescue Exception => e
        log_exception e
      end

    end

    build_resource if build && !resource
  end

  def clear_session
    session[resource_name] = nil
  end

  helper_method :resource, :resource_class, :resource_name
end
