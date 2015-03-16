#encoding: utf-8
class Devise::SessionsController < DeviseController
  prepend_before_filter :require_no_authentication, :only => [ :new, :create ]
  prepend_before_filter :allow_params_authentication!, :only => :create
  prepend_before_filter { request.env['devise.skip_timeout'] = true }
  layout 'main'

  def initialize
    @resp = nil
    @user = nil
    super
  end

  # follow the same logic as in omni authe's authentications_controller.rb
  # the only difference is that we are manually fetching token data etc from ios fb,
  # and dumping all the info here
  def fb_ios
    auth = params
    #question: will a fb token retrieved from omniauth be the same as that retrieved from ios?
    authentication = Authentications.find_by_provider_and_uid(auth['provider'], auth['uid'])
    if authentication
      user = User.find(authentication.user_id)
      user = resource_class::user_object_by_role user.role, user.id
      render :json => {
          :status => :ok,
          :type => :existing_user,
          :user_id => user.id,
          :basic_info => user.basic_info
      }
    elsif current_user
      current_user.authentications.create!(:provider => auth['provider'], :uid => auth['uid'])
      render :json => {
          :status => :ok,
          :type => :existing_user,
          :user_id => user.id,
          :basic_info => user.basic_info
      }
    else
      user = resource_class::from_facebook_email auth[:email]
      user = resource_class::user_object_by_role user.role, user.id

      if user
        user_id = user.apply_mobileauth(auth, 'facebook')
        render :json => {
                          :status => :ok,
                          :type => :existing_user,
                          :user_id => user_id,
                          :basic_info => user.basic_info
        }
      else
        # this where they still have to create an account,
        # we just piggy back off the info provided by fb
        #session[:omniauth] = omni
        redirect_to new_personal_path
      end
    end
  end

  # GET /resource/sign_in
  def new
    respond_to do |format|
      format.html {
        @header = 'shared/sign_in_header'
        self.resource = resource_class.new(sign_in_params)
        clean_up_passwords(resource)
        respond_with(resource, serialize_options(resource))
      }
      format.json {
        begin
          data = JSON::parse params[:data]

          (@resp = {:status => :error, :message => t('api.errors.invalid_request')}) and return unless data

          @user = resource_class::find_for_authentication :email => data['username']
          (@resp = {:status => :error, :message => t('api.errors.invalid_token')}) and return unless user && user.valid_password?(data['password'])
          (@resp = {:status => :error, :message => t('activerecord.errors.models.user.attributes.enabled.disabled')}) and return unless user.enabled?

          system = data['device_system']
          system ||= 'android'

          device_id = data['device_id']
          device_id = device_id.gsub /\-/, ' ' if system.to_s.downcase == 'ios'

          @resp = {:status => :ok}.merge(user.api_login(system, device_id))
        rescue Exception => e
          raise_exception e
        ensure
          render_resp
        end
      }
    end

  end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    unless self.resource.enabled?
      self.resource.errors[:enabled] << t('activerecord.errors.models._user.attributes.enabled.disabled')
      respond_with resource, :location => root_path
      return
    end
    sign_in(resource_name, resource)
    respond_with resource, :location => after_sign_in_path_for(resource)
  end

  def personal
    self.resource = resource_class::find_for_authentication :email => params[:user]['email']

    flash[:error] = t('devise.sessions.no_user') and redirect_to personal_login_path and return unless self.resource

    unless self.resource.valid_password?params[:user]['password']
      flash[:error] = t('devise.sessions.no_user')
      respond_with(self.resource, :location => personal_login_path)
      return
    end

    unless resource.enabled?
      flash[:error] = t('devise.sessions.disabled')
      respond_with resource, :location => personal_login_path
      return
    end

    unless Role::personal? resource
      flash[:error] = t('devise.sessions.no_rights', :link => self.resource.login_path)
      respond_with resource, :location => personal_login_path
      return
    end


    sign_in(resource_name, resource)

    respond_with resource, :location => '/request'
  end

  def business
    self.resource = resource_class::find_for_authentication :email => params[:user]['email']

    flash[:error] = t('devise.sessions.no_user') and redirect_to business_login_path and return unless self.resource

    unless self.resource.valid_password?params[:user]['password']
      flash[:error] = t('devise.sessions.no_user')
      respond_with(self.resource, :location => business_login_path)
      return
    end

    unless resource.enabled?
      flash[:error] = t('devise.sessions.disabled')
      respond_with resource, :location => business_login_path
      return
    end

    unless Role::business? resource
      flash[:error] = t('devise.sessions.no_rights', :link => self.resource.login_path)
      respond_with resource, :location => business_login_path
      return
    end

    sign_in(resource_name, resource)

    respond_with resource, :location => '/request'
  end

  # DELETE /resource/sign_out
  def destroy
    respond_to do |format|
      format.html {
        redirect_path = after_sign_out_path_for(resource_name)
        signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
        set_flash_message :notice, :signed_out if signed_out && is_navigational_format?
        #head :no_content

        redirect_to redirect_path
        return
      }
      format.json {
        begin
          data = JSON.parse params[:data]
          user = validate data
          return unless user
          user.api_logout
          @resp = {:status => :ok}
        rescue Exception => e
          @resp = {:status => :error, :message => e.to_s}
        ensure
          @resp ||= {:status => :error, :message => 'some error'}
          render json: @resp
        end
      }
    end
  end

  protected

  def sign_in_params
    devise_parameter_sanitizer.sanitize(:sign_in)
  end

  def serialize_options(resource)
    methods = resource_class.authentication_keys.dup
    methods = methods.keys if methods.is_a?(Hash)
    methods << :password if resource.respond_to?(:password)
    { :methods => methods, :only => [:password] }
  end

  def auth_options
    { :scope => resource_name, :recall => "#{controller_path}#new" }
  end

  # @return [User]
  def validate(data)
    (@resp = {:status => :error, :message => t('api.errors.invalid_request')}) and return false unless data

    user = User::find_by_api_token data['token']
    (@resp = {:status => :error, :message => t('api.errors.incorrect_token')}) and return false unless user
    (@resp = {:status => :error, :message => t('api.errors.expired_token')}) and return false if user.token_expire && Time.now > user.token_expire

    user
  end

  # @return [User]
  def user
    @user
  end

  # @param [Exception] e
  def raise_exception(e)
    @resp = {:status => e.to_s, :message => e.to_s, :backtrace => e.backtrace.to_json}
    log_exception e
  end

  def render_resp
    @resp ||= {:status => :error,:message => 'some error'}

    data = {
        :action => params[:action],
        :user_type => :session,
        :date => Time.now,
        :request => params.to_json,
        :response => @resp.to_json
    }

    if user
      data[:user_id] = user.id
      data[:device_id] = user.device_id
      data[:device_system] = user.device
    end

    ClientActivityHistory::create(data)
    render json: @resp
  end

end
