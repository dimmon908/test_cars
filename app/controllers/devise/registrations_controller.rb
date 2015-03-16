#encoding: utf-8
class Devise::RegistrationsController < DeviseController
  prepend_before_filter :require_no_authentication, :only => [ :cancel ]
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy]
  layout 'main'

  # GET /resource/sign_up
  def new
    @header = 'shared/sign_up_header'
    build_resource({})
    modify_by_session
    respond_with self.resource
  end

  def modify_by_session
    return unless session[:omniauth]

    #raise Exception, YAML::dump(session[:omniauth])

    data = session[:omniauth].info
    data ||= session[:omniauth][:info]
    return unless data

    resource.email = data.email if data.email
    resource.first_name = data.first_name if data.first_name
    resource.last_name = data.last_name if data.last_name
    resource.photo = data.image if data.image

    resource.uid = session[:omniauth].uid  rescue nil
    resource.provider = session[:omniauth].provider rescue nil
    resource.token = session[:omniauth].credentials.token rescue nil
    resource.token_secret = session[:omniauth].credentials.token_secret rescue nil

    if data.name
      resource.first_name = data.name.split(' ').first
      resource.last_name = data.name.split(' ').last
    end
  end

  # POST /resource
  def create
    build_resource(sign_up_params)

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  # GET /resource/edit
  def edit
    render :edit
  end

  # PUT /resource
  # We need to use a copy of the resource because we don't want to change
  # the current user in place.
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    if update_resource(resource, account_update_params)
      if is_navigational_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
            :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  # DELETE /resource
  def destroy
    resource.destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message :notice, :destroyed if is_navigational_format?
    respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  def cancel
    expire_session_data_after_sign_in!
    redirect_to new_registration_path(resource_name)
  end

  def valid_pass
    resource = resource_class::find params[:id]
    if resource.valid_password? params[:old_password]
      render json: {:status => :ok}
    else
      render json: {:status => :error, :message => 'Invalid old password'}, :status =>  404
    end
  end

  def change_password
    check_auth
    user = resource_class.find params[:id]
    resource = params[resource_name]
    if user.nil? || resource.nil?
      render :json => {message: 'Request invalid'}, :status => 404 and return if request.xhr?
      redirect_to root_path
      return
    end

    render :json => {message: I18n.t('model.errors.custom.old_password')}, :status => 404 and return unless user.valid_password? resource['current_password']

    user.password = resource['password']
    user.password_confirmation = resource['password_confirmation']

    if user.save

      user.send_change_password_data

      #user.unlock_access! rescue nil
      sign_in(user, :bypass => true)

      render :nothing => true, :status => 200 and return if request.xhr?
      redirect_to '/user'
      return
    end

    render :json => {message: user.errors.messages.to_s}, :status => 404 and return if request.xhr?
    redirect_to root_path
  end

  def change_email
    check_auth
    user = resource_class.find params[:id]
    resource = params[resource_name]
    if user.nil? || resource.nil?
      render :json => {:status => :error,message: 'Request invalid'}, :status => 404 and return if request.xhr?
      redirect_to root_path
      return
    end

    render :json => {:status => :error,message: I18n.t('model.errors.custom.old_password')}, :status => 404 and return unless user.email.to_s == resource['email']
    render :json => {:status => :error,message: I18n.t('model.errors.custom.invalid_email')}, :status => 404 and return if resource['email_new'].to_s == ''

    user.params['old_email'] = user.email
    user.email = resource['email_new']
    if user.save(:validate => false)
      user.send_change_email
      #user = User::user_object_by_role(user.role, user.id)

      render :json => {:status => :ok, :email => user.email}, :status => 200 and return if request.xhr?
      redirect_to '/user'
      return
    end

    render :json => {:status => :error, message: user.errors.messages.to_s}, :status => 404 and return if request.xhr?
    redirect_to root_path
  end

  def change_phone
    check_auth
    user = resource_class.find params[:id]
    resource = params[resource_name]
    if user.nil? || resource.nil?
      render :json => {:status => :error,message: 'Request invalid'}, :status => 404 and return if request.xhr?
      redirect_to root_path
      return
    end

    resource['old_phone'] ||= resource['old_phone'].to_s.gsub(/[ \+\-\(\)]/, '')

    render :json => {:status => :error,message: I18n.t('model.errors.custom.old_password')}, :status => 404 and return unless user.phone.to_s == resource['phone']

    render :json => {:status => :error,message: I18n.t('model.errors.custom.invalid_phone')}, :status => 404 and return if resource['phone_new'].to_s == ''

    user.phone = resource['phone_new']
    if user.save(:validate => false)
      render :json => {:status => :ok, :phone => user.phone}, :status => 200 and return if request.xhr?
      redirect_to '/user'
      return
    end

    render :json => {:status => :error, message: user.errors.messages.to_s}, :status => 404 and return if request.xhr?
    redirect_to root_path
  end

  protected

  def update_needs_confirmation?(resource, previous)
    resource.respond_to?(:pending_reconfirmation?) &&
        resource.pending_reconfirmation? &&
        previous != resource.unconfirmed_email
  end

  # By default we want to require a password checks on update.
  # You can overwrite this method in your own RegistrationsController.
  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  # Build a devise resource passing in the session. Useful to move
  # temporary session data to the newly created user.
  def build_resource(hash=nil)
    self.resource = resource_class.new_with_session(hash || {}, session)
  end

  # Signs in a user on sign up. You can overwrite this method in your own
  # RegistrationsController.
  def sign_up(resource_name, resource)
    sign_in(resource_name, resource)
  end

  # The path used after sign up. You need to overwrite this method
  # in your own RegistrationsController.
  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource)
  end

  # The path used after sign up for inactive accounts. You need to overwrite
  # this method in your own RegistrationsController.
  def after_inactive_sign_up_path_for(resource)
    respond_to?(:root_path) ? root_path : "/"
  end

  # The default url to be used after updating a resource. You need to overwrite
  # this method in your own RegistrationsController.
  def after_update_path_for(resource)
    signed_in_root_path(resource)
  end

  # Authenticates the current scope and gets the current resource from the session.
  def authenticate_scope!
    send(:"authenticate_#{resource_name}!", :force => true)
    self.resource = send(:"current_#{resource_name}")
  end

  def sign_up_params
    devise_parameter_sanitizer.sanitize(:sign_up)
  end

  def account_update_params
    devise_parameter_sanitizer.sanitize(:account_update)
  end
end
