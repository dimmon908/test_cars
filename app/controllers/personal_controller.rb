#encoding: utf-8
require './app/models/classes/personal_account'
class PersonalController < Devise::RegistrationsController
  layout 'main'

  def login
    render template: '/devise/sessions/new', :locals => {:web_path => personal_login_path}
  end

  # GET /resource/sign_up
  def new
    @header = 'shared/sign_up_header'
    @account_type = 'your personal'
    @switch_to_account_type = :business
    @switch_to_link = new_busines_path
    build_resource({})
    modify_by_session
    resource.need_validate = true
    respond_with self.resource
  end

  def create
    build_resource(sign_up_params)
    if resource.save
      redirect_to "/personal/activate/#{resource.id}"
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def create_account
    #data = JSON.parse params[:data]

    Rails.logger.fatal({:data => params, :type => :create_account_params}.to_s)
    if params[:android].blank?
      data = sign_up_params
    else
      data = params
    end

    Rails.logger.fatal( {:data => data, :type => :create_account_data}.to_s)

    data.delete 'card_expire'
    data.delete :card_expire

    build_resource(data)
    resource.need_validate = true

    begin
      if resource.save
        render json: {:status => :ok, :user_id => resource.id }
      else
        render json: {:status => :errors, :message => resource.errors.messages.to_json}
      end
    rescue Exception => e
      render json: {:status => :errors, :message => e.to_s}
    end
  end

  def update_account
    user = resource_class.find params[:id] rescue nil
    resource = params[resource_name]

    render :json => {message: 'Request invalid'}, :status => 404 and return unless user && resource
    render :json => { :status => :ok } and return if user.update_attributes(resource)
    render :json => {:status => :error, message: user.errors.messages.to_s}, :status => 404
  end

  def index
    unless user_signed_in?
      redirect_to root_path
      return
    end
    if current_user.role.internal_name != 'personal'
      redirect_to '/user'
      return
    end
    self.resource = resource_class.find current_user.id
  end

  def show
    unless can? :show_user, current_user
      redirect_to root_path
      return
    end
    self.resource = resource_class.find params[:id]
  end

  def edit
    self.resource= resource_class::find params[:id]if params[:id]
    render :edit
  end

  def update
    user = resource_class.find params[:id]
    resource = params[resource_name]
    if user.nil? || resource.nil?
      render :json => {message: 'Request invalid'}, :status => 404 and return if request.xhr?
      redirect_to root_path
      return
    end

    resource['password'] ||= resource['password'].to_s
    resource['first_name'] ||= user.first_name.to_s
    resource['last_name'] ||= user.last_name.to_s
    if user.update_attributes(resource)
      render :json => {
          :status => :ok,
          :img => user.user_profile.photo.url(:small),
          :phone => user.phone,
          :email => user.email
      }, :status => 200 and return if request.xhr?
      redirect_to '/user'
      return
    end
    render :json => {:status => :error, message: user.errors.messages.to_s}, :status => 404 and return if request.xhr?
    redirect_to root_path
  end

  def destroy
    if params[:id]
      User::find(params[:id]).destroy
    else
      resource.destroy
    end
    set_flash_message :notice, :destroyed if is_navigational_format?
    redirect_to request.referrer and return rescue nil
    respond_with_navigational(resource){ redirect_to '/' }
  end

  #@return [Classes::PersonalAccount]
  def resource
    instance_variable_get(:"@#{resource_name}")
  end

  #@param [Classes::PersonalAccount]
  #@return [Classes::PersonalAccount]
  def resource=(new_resource)
    instance_variable_set(:"@#{resource_name}", new_resource)
  end

  def success
    self.resource = resource_class::find params[:id]
  end

  def activate
    self.resource = resource_class::find params[:id]
  end

  def send_activate
    self.resource = resource_class::find params[:id]

    render json: {:status => :error, :message => t('user.no_such_user')} and return unless self.resource

    begin
      type = params[:activate].to_sym

      self.resource.generate_activation_data

      @request_host = request.host
      @request_host += ":#{request.port}" unless request.port == 80

      if type == :email
        EmailPersonal.success(
          self.resource,
          Email::find_by_internal_name(:personal_register_confirm),
          {:last_name => self.resource.last_name, :first_name => self.resource.first_name, :email => self.resource.email, :link => "http://#{@request_host}/personal/activate_token/#{self.resource.activate_data.token}", :code => self.resource.activate_data.code }
        ).deliver
      elsif type == :sms
        @sms_params = {:last_name => self.resource.last_name, :first_name => self.resource.first_name, :email => self.resource.email, :code => self.resource.activate_data.code}
        sms = SmsMessagesPull.create([
          :user_id => self.resource.id,
          :to => self.resource.phone,
          :sms_message => SmsMessage::find_by_internal_name(:personal_activate),
          :status => :new,
          :params => @sms_params
        ])[0]
        sms.send_message
      end

      render json: {:status => :ok}
    rescue Exception => e
      log_exception e
      render json: {:status => :error, :message => e.to_s}
    end
  end

  def activate!
    self.resource = resource_class::find params[:id]
    if params[:code] &&
        !params[:code].blank? &&
        resource &&
        resource.activate_by_code!(params[:code])

      sign_in User::find self.resource.id
      redirect_to "/personal/success/#{self.resource.id}"
      return
    end
    redirect_to "/personal/activate/#{self.resource.id}"
  end

  def activate_token
    data = ActivateData::find_by_token(params[:token]) rescue nil
    redirect_to root_path and return unless data
    user = User::find data.user_id
    redirect_to root_path and return unless user
    if user.activate!
      redirect_to "/personal/success/#{user.id}"
    else
      redirect_to root_path
    end
  end

  private
  def build_resource(hash=nil)
    self.resource = resource_class.new_with_session(hash || {}, session)
  end

  def resource_name
    'user'
  end

  def resource_class
    Classes::PersonalAccount
  end

  helper_method :resource, :resource_class, :resource_name

end