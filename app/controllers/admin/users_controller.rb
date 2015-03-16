class Admin::UsersController < ApplicationController
  before_filter :authenticate_user!
  layout 'admin'
  respond_to :js, :html, :json

  def new
    check_auth(:admin, :business_part)
    build_resource({})
    respond_with self.resource
  end

  def create
    partner = Classes::BusinessAccount::find(params[resource_name]['partner_id']) if params[resource_name] && params[resource_name]['partner_id'] rescue nil
    partner ||= Classes::BusinessAccount::find current_user.partner_id

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

  def edit
    check_auth(:admin, :business_part)
    self.resource= resource_class::find params[:id] if params[:id]
    render :file => 'sub_account/edit', :layout => false
  end

  def limit
    check_auth(:admin, :business_part)
    self.resource= resource_class::find params[:id] if params[:id]
    @only_credit = true
    render :file => 'sub_account/edit', :layout => false
  end

  def status
    resp = {}
    begin
      user = resource_class.find params[:id]
      user.status = params[:status]
      user.password = ''
      if user.save
        resp = {:status => :ok}
      else
        resp = {:status => :error, :message => user.errors.messages}
      end
    rescue Exception => e
      resp = {:status => :error, :message => e.message}
    ensure
      render json: resp
    end


  end

  def show
    check_auth(:admin, :business_part)
    self.resource= resource_class::find params[:id] if params[:id]
  end

  def update
    user = resource_class.find params[:id]
    resource = params[resource_name]
    if user.nil? || resource.nil?
      redirect_to sub_account_index_path
      return
    end
    if user.update_attributes(resource)
      redirect_to sub_account_index_path
      return
    end
    redirect_to sub_account_index_path
  end

  def disable
    if can? :disable, :all
      user = resource_class.find params[:id]
      user.status = 0
      user.save :validate => false

      render json: {:status => :ok}
    else
      render json: {:status => :error, :message => 'No rights'}
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
