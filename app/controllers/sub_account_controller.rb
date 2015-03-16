#encoding: utf-8
class SubAccountController < Devise::RegistrationsController
  before_filter :authenticate_user!
  layout 'main'
  respond_to :js, :html, :json

  def index
    if can? :all, current_user
      @accounts = Classes::SubAccount::where(:role_id => Role::where(:internal_name => ['sub_account', 'sub_account_with_admin'])).all
    elsif can? :sub_accounts, current_user
      @accounts = Classes::SubAccount::where('role_id in (?) AND partner_id = ?', Role::where(:internal_name => ['sub_account', 'sub_account_with_admin']), current_user.id).all
    end
    @accounts ||= []
  end

  def show
    self.resource= resource_class::find params[:id]if params[:id]
  end

  def create
    partner = Classes::BusinessAccount::find(params[resource_name]['partner']) if params[resource_name] && params[resource_name]['partner'] rescue nil
    partner ||= Classes::BusinessAccount::find current_user.id

    params[resource_name]['partner'] = partner
    build_resource(params[resource_name])

    if resource.save
      render json: {:status => :ok} and return if request.xhr?
      redirect_to sub_account_index_path
    else
      render json: {:status => :error, :message => resource.errors.messages.to_json} and return if request.xhr?
      respond_with resource
    end
  end

  def new
    build_resource({})
    respond_with self.resource
  end

  def edit
    self.resource= resource_class::find params[:id]if params[:id]
  end

  def update
    user = resource_class.find params[:id]
    resource = params[resource_name]
    render json: {:status => :error, :message => 'invalid request'} and return unless user && resource

    (resource['partner_id'] = resource['partner']) and (resource.delete 'partner') if resource['partner']
    resource['password']   ||= resource['password'].to_s
    if user.update_attributes(resource)
      render json: {:status => :ok }
    else
     render json: {:status => :error, :message => user.errors.messages }
    end
  end

  def destroy
    if params[:id]
      User::find(params[:id]).destroy rescue nil
    else
      resource.destroy
    end
    redirect_to sub_account_index_path
  end

  def resource
    instance_variable_get(:"@#{resource_name}")
  end
  def resource=(new_resource)
    instance_variable_set(:"@#{resource_name}", new_resource)
  end

  def authenticate_SubAccount!(args)
    true
  end

  def current_SubAccount
    unless @current
      @current = resource_class::find current_user.id
    end
    @current
  end

  def success
  end

  private
  def build_resource(hash=nil)
    self.resource = resource_class.new_with_session(hash || {}, session)
  end

  def resource_name
    'SubAccount'
  end

  def resource_class
    Classes::SubAccount
  end

  helper_method :resource, :resource_class, :resource_name
end