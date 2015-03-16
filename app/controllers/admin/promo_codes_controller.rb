#encoding: utf-8
module Admin
  class PromoCodesController < ApplicationController
    before_filter :authenticate_user!
    respond_to :js, :html, :json
    layout 'admin'

    def index
      check_auth
    end

    def new
      check_auth
      build_resource({})
      @cars = Car::select([:id, :place_number, :model_name]).where('id NOT IN (?)', Driver::select(:car_id).all.to_s).all.collect{|p| [p.id, "[#{p.place_number}]    #{p.model_name}"]}
      respond_with self.resource
    end

    def create
      build_resource(params[resource_name])
      if resource.save
        render :json => {status: :ok} and return if request.xhr?
        redirect_to admin_driver_index_path
      else
        #@cars = Car::select([:id, :place_number, :model_name]).where('id NOT IN (?)', Driver::select(:car_id).all.to_s).all.collect{|p| [p.id, "[#{p.place_number}]    #{p.model_name}"]}
        #respond_with resource
        render :json => {status: :error, :message => resource.errors.messages.to_json} and return if request.xhr?
        render :new
      end
    end

    def edit
      check_auth
      redirect_to admin_driver_index_path and return unless resource_class.where(:id => params[:id]).any?

      self.resource = resource_class::find params[:id]
      render :edit
    end

    def update
      driver = resource_class::find params[:id]
      resource = params[resource_name]

      if driver.nil? || resource.nil?
        redirect_to admin_promo_codes_path
        return
      end

      if driver.update_attributes(resource)
        render :json => {status: :ok} and return if request.xhr?
      else
        render :json => {status: :error, :message => resource.errors.messages.to_json} and return if request.xhr?
      end
      redirect_to admin_promo_codes_path
    end

    def show
      check_auth
      driver = resource_class::find params[:id]
      if driver.nil?
        redirect_to root_path
        return
      end
      self.resource = driver
    end

    def destroy
      driver = resource_class::find params[:id]
      driver.destroy
      redirect_to root_path
    end

    def resource=(new_resource)
      @resource = new_resource
    end

    def resource
      @resource ||= resource_class.new
    end

    private
    def build_resource(hash=nil)
      self.resource = resource_class.new(hash || {}, session)
    end

    def resource_name
      'promo'
    end

    def resource_class
      PromoCode
    end

    helper_method :resource, :resource_class, :resource_name
  end
end