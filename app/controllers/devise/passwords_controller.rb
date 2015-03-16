#encoding: utf-8
class Devise::PasswordsController < DeviseController
  prepend_before_filter :require_no_authentication
  # Render the #edit only if coming from a reset password email link
  append_before_filter :assert_reset_token_passed, :only => :edit
  layout 'main'

  # GET /resource/password/new
  def new
    respond_to do |format|
      format.html {
        @header = 'shared/forget_password_header'
        self.resource = resource_class.new
      }
      format.json {
        data = JSON::parse params[:data]
        render json: {:status => :error, :message => t('api.errors.invalid_request')} and return unless data
        user = resource_class::find_for_authentication :email => data['username'] rescue nil
        render json: {:status => :error, :message => t('api.errors.none_username')} and return unless user

        user.send_reset_password_instructions if user.persisted?
        if successfully_sent?(user)
          render json: {:status => :ok}
        else
          render json: {:status => :error, :message => t('api.errors.email_error')}
        end
      }
    end
  end

  # POST /resource/password
  def create
    begin
      self.resource = resource_class::find_for_authentication :email => params[:user]['find_element'] rescue nil

      unless self.resource
        session[:errors] ||= []
        session[:errors] << 'No such user'
        self.resource ||= resource_class.new
        redirect_to '/password/fail'
        return
      end

      self.resource.find_element = params[:user]['find_element']

      self.resource.send_reset_password_instructions

      if successfully_sent?(self.resource)
        redirect_to '/password/success'
      else
        respond_with(resource)
      end

    rescue Exception => e
      log_exception e
      session[:errors] ||= []
      session[:errors] << e.to_s

      self.resource ||= resource_class.new
      redirect_to '/password/fail'
    end

  end

  # POST /retrieve_password
  def retrieve_password
    begin
      self.resource = resource_class::find_for_authentication :email => params[:user]['find_element'] rescue nil

      unless self.resource
        render json: { :status => :error,
                       :message => 'No such user'
        }
        return
      end

      self.resource.find_element = params[:user]['find_element']

      self.resource.send_reset_password_instructions

      if successfully_sent?(self.resource)
        render json: { :status => :ok }
        return
      else
        respond_with(resource)
      end

    rescue Exception => e
      render json: { :status => :error,
                     :message => 'unkown error'
      }
    end

  end

  def success
    @header = 'shared/forget_password_header'
  end

  def fail
    @header = 'shared/forget_password_header'
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    token = Devise.token_generator.digest(self, :reset_password_token, params[:reset_password_token])
    self.resource = User::find_by_reset_password_token(token) rescue nil

    redirect_to '/' and return unless self.resource

    if Role::admin? resource
      resource.reset_password_token = params[:reset_password_token]
      render file: '/admin/password/_edit.erb', :layout => 'admin_login'
    else
      self.resource = resource_class.new
      resource.reset_password_token = params[:reset_password_token]
    end


  end

  # PUT /resource/password
  def update
  self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with resource, :location => after_resetting_password_path_for(resource)
    else
      respond_with resource
    end
  end

  protected
    def after_resetting_password_path_for(resource)
      after_sign_in_path_for(resource)
    end

    # The path used after sending reset password instructions
    def after_sending_reset_password_instructions_path_for(resource_name)
      new_session_path(resource_name) if is_navigational_format?
    end

    # Check if a reset_password_token is provided in the request
    def assert_reset_token_passed
      if params[:reset_password_token].blank?
        set_flash_message(:alert, :no_token)
        redirect_to new_session_path(resource_name)
      end
    end

    # Check if proper Lockable module methods are present & unlock strategy
    # allows to unlock resource on password reset
    def unlockable?(resource)
      resource.respond_to?(:unlock_access!) &&
        resource.respond_to?(:unlock_strategy_enabled?) &&
        resource.unlock_strategy_enabled?(:email)
    end
end
