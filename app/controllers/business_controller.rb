#encoding: utf-8
require './app/models/classes/business_account'
class BusinessController < Devise::RegistrationsController
  prepend_before_filter :require_no_authentication, :only => [ :cancel ]
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy]
  layout 'main'

  def login
    render template: '/devise/sessions/new'
  end

  # GET /resource/sign_up
  def new
    @header = 'shared/sign_up_header'
    @account_type = 'business'
    @switch_to_account_type = 'regular'
    @switch_to_link = new_personal_path
    build_resource({})
    resource.validate_card = true
    modify_by_session
    respond_with self.resource
  end

  def create
    build_resource(sign_up_params)
    resource.need_validate = true if params[:business_mode].to_s == :CC

    if resource.credit_card.blank? && resource.need_approve.blank?
      resource.errors[:payment] << 'Must accept Net Terms or add credit card'
      clean_up_passwords resource
      respond_with resource
      return
    end

    if resource.save
      redirect_to "/business/success/#{resource.id}"
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def index
    unless user_signed_in?
      redirect_to root_path
      return
    end
    if current_user.role.internal_name != 'business'
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
    render :json => {message: user.errors.messages.to_s}, :status => 404 and return if request.xhr?

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
    respond_with_navigational(resource){ redirect_to root_path }
  end

  def resource
    instance_variable_get(:"@#{resource_name}")
  end
  def resource=(new_resource)
    instance_variable_set(:"@#{resource_name}", new_resource)
  end

  def authenticate_BusinessAccount!(args)
    true
  end

  def current_BusinessAccount
    unless @current
      @current = resource_class::find current_user.id
    end
    @current
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

      if type == :email
        EmailPersonal.success(
            self.resource,
            Email::find_by_internal_name(:business_register_confirm),
            {:last_name => self.resource.last_name, :first_name => self.resource.first_name, :email => self.resource.email, :link => "#{request.host}/business/activate/#{self.resource.activate_data.token}", :code => self.resource.activate_data.code }
        ).deliver
      elsif type == :sms
        sms = SmsMessagesPull.create([
           :user_id => self.resource.id,
           :to => self.resource.phone,
           :sms_message => SmsMessage::find_by_internal_name(:business_activate),
           :status => :new,
           :params => {:last_name => self.resource.last_name, :first_name => self.resource.first_name, :email => self.resource.email, :code => self.resource.activate_data.code, :link => "#{request.host}/personal/activate/#{self.resource.activate_data.token}" }
         ])[0]
        sms.send_sms
      end

      render json: {:status => :ok}
    rescue Exception => e
      log_exception e
      render json: {:status => :error, :message => e.to_s}
    end
  end

  def activate!
    self.resource = resource_class::find params[:id]
    if self.resource.activate_by_code! params[:code]
      sign_in User::find self.resource.id
      redirect_to root_path
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
      sign_in user ,:bypass => false
    end
    redirect_to root_path
  end

  private
  def build_resource(hash=nil)
    self.resource = resource_class.new_with_session(hash || {}, session)
  end

  def resource_name
    'user'
  end

  def resource_class
    Classes::BusinessAccount
  end

  helper_method :resource, :resource_class, :resource_name
end
