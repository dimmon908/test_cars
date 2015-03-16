#encoding: utf-8
module Admin
  class RequestController < ApplicationController
    before_filter :authenticate_user!
    respond_to :js, :html, :json
    layout 'admin'
    set_tab :requests

    def index
      check_auth(:admin, :business_part)
      @data = Request::where('`status` != ?', :future).all
    end

    def finish
      render :json => {:status => :error, :message => 'now such trip'} and return unless Request.where(:id => params[:id]).any?
      trip = Request.find params[:id]
      if trip.finished! true
        render :json => {:status => :ok, :id => params[:id]}
      else
        render :json => {:status => :error, :message => 'error'}
      end
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
        redirect_to '/admin/request'
      else
        #@cars = Car::select([:id, :place_number, :model_name]).where('id NOT IN (?)', Driver::select(:car_id).all.to_s).all.collect{|p| [p.id, "[#{p.place_number}]    #{p.model_name}"]}
        #respond_with resource
        render :new
      end
    end

    def edit
      check_auth
      driver = resource_class::find params[:id] rescue nil
      if driver.nil?
        redirect_to admin_driver_index_path
        return
      end
      self.resource = driver
      render :edit
    end

    def update
      driver = resource_class::find params[:id]
      resource = params[resource_name]

      if driver.nil? || resource.nil?
        redirect_to admin_driver_index_path
        return
      end

      driver.update_attributes(resource)
      redirect_to admin_driver_index_path
    end

    def show
      check_auth(:admin, :business_part)
      redirect_to '/admin/request' and return unless resource_class::where(:id => params[:id]).any?
      @data = params[:filter].to_s

      request = resource_class::find params[:id]
      self.resource = request
    end

    def destroy
      trip = resource_class::find params[:id]
      trip.destroy
      redirect_to :back, :method => :get
    end

    def resource=(new_resource)
      @resource = new_resource
    end

    def resource
      @resource ||= resource_class.new
    end

    def future_rides
      check_auth(:admin, :business_part)
      @tab = :future_rides
      @data = Request::where(:status => :future).all
      render :action => 'future_rides'
    end

    def cancel
      check_auth(:admin, :business_part)
      trip = Request::find params[:id] rescue nil

      redirect_to "/admin/request/#{params[:id]}" and return unless trip

      trip.cancelled_user_id = current_user.id
      trip.canceled!(true)
      trip.notify_driver
      trip.notify_client
      ApnPushMessages.send 'KILREQ', trip

      redirect_to "/admin/request/#{params[:id]}"
    end

    private
    def build_resource(hash=nil)
      self.resource = resource_class.new(hash || {}, session)
    end

    def resource_name
      'request'
    end

    def resource_class
      Request
    end

    helper_method :resource, :resource_class, :resource_name
  end
end
