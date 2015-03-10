#encoding: utf-8
require './app/models/classes/business_account'
module Admin
class BusinessController < ApplicationController
  before_filter :authenticate_user!
  respond_to :js, :html, :json
  layout 'admin'

  # GET /resource/sign_up
  def new
    check_auth
    build_resource({})
    respond_with self.resource
  end

  def create
    build_resource(params[resource_name])

    resource.need_validate = true

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

  def show
    check_auth
    self.resource = resource_class.find params[:id]
  end

  def edit
    check_auth

    self.resource = resource_class::find params[:id] if params[:id]
    render :edit, :layout => false
  end

  def payment
    check_auth

    self.resource.admin_id = current_user.id
    self.resource.user_id = params[:id]
  end

  def create_payment
    self.resource= resource_class::find params[:id]if params[:id]
    data = params[:payment]
    payment = Payment.new(data)
    payment.save

    render json: {:status => :ok, :id => payment.id}
  end

  def update
    user = resource_class.find params[:id] rescue nil
    resource = params[resource_name]
    if user.nil? || resource.nil?
      render :json => {:status => :error, message: 'Request invalid'} and return if request.xhr?
      redirect_to 'admin/business'
      return
    end

    user.validate_card = false

    resource['password'] ||= resource['password'].to_s
    resource['first_name'] ||= user.first_name.to_s
    resource['last_name'] ||= user.last_name.to_s
    if user.update_attributes(resource)
      render :json => {:status => :ok} and return if request.xhr?
      redirect_to '/admin/business'
      return
    end

    render :json => {:status => :error, message: user.errors.messages.to_s} and return if request.xhr?
    redirect_to 'admin/business'
  end

  def destroy
    if params[:id]
      User::find(params[:id]).destroy
    else
      resource.destroy
    end

    redirect_to '/admin/business'
  end

  def resource
    instance_variable_get(:"@#{resource_name}")
  end
  def resource=(new_resource)
    instance_variable_set(:"@#{resource_name}", new_resource)
  end

  private
  def build_resource(hash=nil)
    self.resource = resource_class.new(hash || {})
  end

  def resource_name
    'user'
  end

  def resource_class
    Classes::BusinessAccount
  end

  helper_method :resource, :resource_class, :resource_name
end
end