#encoding: utf-8
require './app/models/classes/admin_account'
require 'query_report/helper'
include DateTimeFormatter
class AdminController < Devise::RegistrationsController
  include QueryReport::Helper
  before_filter :authenticate_user!

  prepend_before_filter :require_no_authentication, :only => [:cancel]
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy]

  layout 'admin'
  set_tab :dashboard

  def index
    check_auth(:admin, :business_part)
    @tab = session[:admin_tab]
    @tab ||= :dashboard
    @tab = @tab.to_sym

    @tab = :dashboard unless @tab
    file = AdminHelper::NAVIGATION[@tab]
    unless file
      @tab = :dashboard
      file = AdminHelper::NAVIGATION[@tab]
    end

    begin
      render file: file
    rescue Exception => e
      log_exception e
      render file: '/admin/dashboard'
    end
  end

  def login
    data = params['user']
    user = User::find_for_authentication :email => data['email']
    unless user && user.valid_password?(data['password'])
      session[:notice] ||= []
      session[:notice] << 'No such user'
      redirect_to '/admin/login'
      return
    end

    sign_in(user, :bypass => true)

    if !user.role?(:admin) && !user.role?(:business) && !user.role?(:sub_account_with_admin)
      session[:notice] ||= []
      session[:notice] << 'No rights'
      redirect_to '/admin/login'
      return
    end

    redirect_to '/admin'
  end

  def list
    render file: '/admin/index'
  end

  def show
    check_auth
    self.resource = resource_class.find current_user.id
    render :layout => 'pdf_admin' if ApplicationHelper::pdf? request
  end

  def update
    check_auth
    user     = resource_class.find params[:id]
    resource = params[resource_name]
    if user.nil? || resource.nil?
      render :json => {message: 'Request invalid'}, :status => 404 and return if request.xhr?
      redirect_to root_path and return
    end
    resource['password']    ||= resource['password'].to_s
    resource['first_name']  ||= user.first_name.to_s
    resource['last_name']   ||= user.last_name.to_s

    Rails.logger.error resource.to_s
    resource['need_notify'] ||= 0
    if user.update_attributes(resource)
      Rails.logger.error user.need_notify

      render :json   => {
          :status => :ok,
          :img    => user.user_profile.photo.url(:small),
          :phone  => user.phone,
          :email  => user.email
      },     :status => 200 and return if request.xhr?
      redirect_to '/user'
      return
    end
    Rails.logger.error user.errors.messages.to_s

    render :json => {:status => :error, message: user.errors.messages.to_s}, :status => 404 and return if request.xhr?
    redirect_to root_path
  end

  def resource
    instance_variable_get(:"@#{resource_name}")
  end

  def resource=(new_resource)
    instance_variable_set(:"@#{resource_name}", new_resource)
  end

  def personal
    check_auth

    if ApplicationHelper.csv? request
      data = Classes::PersonalAccount.users.where(:show => true).order('created_at DESC').paginate(:page => params[:page], :per_page => params[:per_page]) rescue nil
      data ||= []
      send_data(data.to_comma, :type => 'text/csv; charset=utf-8; header=present')
      return
    end

    @tab = :passengers
    render :layout => 'pdf_admin' if ApplicationHelper.pdf? request
  end

  def business

    check_auth
    @tab = :companies

    @data = Classes::BusinessAccount::users.order('created_at DESC').paginate(:page => params[:page], :per_page => params[:per_page]) rescue nil
    @data ||= []

    if ApplicationHelper.csv? request
      send_data(@data.to_comma, :type => 'text/csv; charset=utf-8; header=present')
      return
    end

    render :layout => 'pdf_admin' if ApplicationHelper::pdf? request
  end

  def users
    check_auth(:admin, :business_part)
    @tab = :users

    @data = Classes::SubAccount.get(current_user).order('created_at DESC').paginate(:page => params[:page], :per_page => params[:per_page])

    @data ||= []

    render :layout => 'pdf_admin' and return if ApplicationHelper::pdf? request
    send_data(@data.to_comma, :type => 'text/csv; charset=utf-8; header=present') if ApplicationHelper.csv? request
  end

  def admins
    check_auth
    @tab = :admins
    @data = Classes::AdminAccount::users.order('created_at DESC').paginate(:page => params[:page], :per_page => params[:per_page]) rescue nil
    @data ||= []
    render :layout => 'pdf_admin' if ApplicationHelper::pdf? request
  end

  def sub_accounts
    check_auth(:admin, :business_part)
    @tab = :users
    @data = Classes::SubAccount::users(current_user).paginate(:page => params[:page], :per_page => params[:per_page]) rescue nil
    @data ||= []
    render :layout => 'pdf_admin' if ApplicationHelper::pdf? request
  end

  def emails
    check_auth
    @data = Email.paginate(:page => params[:page], :per_page => params[:per_page])
    render :template => 'admin/email/index'
  end

  def sms
    check_auth
    @data = SmsMessage.paginate(:page => params[:page], :per_page => params[:per_page])
    render :template => 'admin/sms/index'
  end

  def notifications
    check_auth
    @data = Notification.paginate(:page => params[:page], :per_page => params[:per_page])
    render :template => 'admin/notification/index'
  end

  def car
    check_auth
    if ApplicationHelper.csv? request
      @cars = Car.paginate(:page => params[:page], :per_page => params[:per_page]) rescue nil
      @cars ||= []
      send_data @cars.to_comma, :type => 'text/csv; charset=utf-8; header=present'
      return
    end

    @tab = :cars
    render :file => 'admin/car/index', :layout => 'pdf_admin' and return if ApplicationHelper::pdf? request
    render :file => 'admin/car/index'
  end

  def requests
    if ApplicationHelper.csv? request

      if can? :admin, :all
        requests = Request.where('`status` != ?', :future).order('created_at DESC').paginate(:page => params[:page], :per_page => params[:per_page]) rescue nil
      else
        requests = Request.where('`status` != ? AND `user_id` = ?', :future, current_user.partner_id).order('created_at DESC').paginate(:page => params[:page], :per_page => params[:per_page]) rescue nil
      end

      requests ||= []
      send_data requests.all.to_comma, :type => 'text/csv; charset=utf-8; header=present' if ApplicationHelper.csv? request
      return
    end

    check_auth(:admin, :business_part)
    @tab      = :requests
    render :file => 'admin/request/index', :layout => 'pdf_admin' and return if ApplicationHelper::pdf? request
    render :file => 'admin/request/index'
  end

  def future_riders
    check_auth(:admin, :business_part)
    @tab = :future_rides
    if ApplicationHelper::pdf? request
      render :file => 'admin/request/future_rides', :layout => 'pdf_admin'
    else
      render :file => 'admin/request/future_rides'
    end
  end

  def drivers
    if ApplicationHelper.csv? request
      drivers = Driver.order('created_at DESC').paginate(:page => params[:page], :per_page => params[:per_page]) rescue nil
      drivers ||= []
      send_data drivers.to_comma, :type => 'text/csv; charset=utf-8; header=present'
      return
    end

    check_auth

    @tab = :drivers
    render :file => 'admin/driver/index', :layout => 'pdf_admin' and return if ApplicationHelper::pdf? request
    render :file => 'admin/driver/index'
  end

  def report
    check_auth
    @tab = :reports

    if ApplicationHelper::pdf? request
      render :file => 'admin/reports/index', :layout => 'pdf_admin'
    else
      render :file => 'admin/reports/index'
    end

  end

  def dashboard
    check_auth(:admin, :business_part)
    @tab = :dashboard
    respond_to do |format|
      format.html {}
      format.js { render :layout => false }
    end
  end

  def map
    check_auth
    @tab = :map
    respond_to do |format|
      format.html {}
      format.js { render :layout => false }
    end
  end

  def promo_codes
    check_auth
    @tab = :promo_codes

    if ApplicationHelper::pdf? request
      render :file => 'admin/promo_codes/index', :layout => 'pdf_admin'
    else
      render :file => 'admin/promo_codes/index'
    end
  end

  def config_rates
    check_auth
    @tab = :config_rates
    render :file => 'admin/config/rates'
  end

  def configs
    check_auth
    @tab = :configs
    render :file => '/admin/config/index'
  end

  def password
    render file: '/admin/password/_new.erb', :layout => 'admin_login'
  end

  def reset_password

    user = User::find_for_authentication :email => params[:user]['email'] rescue nil
    session[:notice] ||= []

    unless user
      session[:notice] << 'No such email/password'
      redirect_to '/admin/password/new'
      return
    end

    unless Role::admin? user
      session[:notice] << 'No such rights for this user'
      redirect_to '/admin/password/new'
      return
    end

    user.send_reset_password_instructions if user.persisted?
    if successfully_sent?(user)
      session[:notice] << 'Forgotten email was successfully sent'
      redirect_to '/admin/login'
    else
      session[:notice] << 'Error while sending email'
      redirect_to '/admin/password/new'
    end

  end

  def new
    build_resource
    render :layout => false
  end

  def create
    build_resource(params[resource_name])

    begin
      if resource.save
        render json: {:status => :ok}
      else
        render json: {:status => :errors, :message => resource.errors.messages.to_json}
      end
    rescue Exception => e
      render json: {:status => :errors, :message => e.to_s}
    end

  end

  def edit
    self.resource = Classes::AdminAccount::find params[:id]
    render :action => :edit, :layout => false
  end

  def destroy
    if params[:id]
      User::find(params[:id]).destroy
    else
      resource.destroy
    end

    redirect_to '/admin/admins'
  end

  private
  def build_resource(hash=nil)
    self.resource = resource_class.new(hash || {})
  end

  def resource_name
    'user'
  end

  def resource_class
    Classes::AdminAccount
  end

  helper_method :resource, :resource_class, :resource_name
end