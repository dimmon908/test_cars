#encoding: utf-8
module Admin
  class DriverController < ApplicationController
    before_filter :authenticate_user!
    respond_to :js, :html, :json
    layout 'admin'


    # GET/POST
    def drivers_map
      map
    end

    # GET/POST
    def map
      check_auth
      begin
        render json: {status: :ok, data: Driver.for_map }
      rescue Exception => e
        log_exception e
        render json: {status: :error, :message => e.to_s }
      end
    end

    # GET/POST
    def message
      render json: {:status => :error, :message => 'Empty message'} and
          return if params[:message].blank?

      render json: {:status => :error, :message => 'No driver'} and
          return unless Driver::where(:id => params[:id]).any?

      driver = Driver::find params[:id]
      driver.send_push_message params[:message].to_s, current_user.id
      render json: {:status => :ok}
    end

    def broadcast
      begin
        render json: {:status => :error, :message => 'Empty message'} and
            return if params[:message].blank?

        render json: {:status => :error, :message => 'No drivers'} and
            return if Driver::online.count == 0

        Driver::online.each {|driver|
          res = driver.send_push_message params[:message].to_s, current_user.id
        }

        render json: {:status => :ok}
      rescue Exception => e
        render json: {:status => :error, :message => e.to_s}
      end
    end

    def logoff
      begin
        render json: {:status => :error, :message => 'No such driver'} and return unless Driver::where(:id => params[:id]).any?

        resource = Driver::find params[:id]
        resource.online = 0
        resource.save :validate => true

        render json: {:status => :ok}
      rescue Exception => e
        render json: {:status => :error, :message => e.to_s}
      end
    end

    def lock
      begin
        render json: {:status => :error, :message => 'No such driver'} and return unless Driver::where(:id => params[:id]).any?
        resource = Driver::find params[:id]
        resource.lock = params[:lock]
        resource.save :validate => true
        render json: {:status => :ok}
      rescue Exception => e
        render json: {:status => :error, :message => e.to_s}
      end
    end

    def requests
      check_auth
      @data = Request::by_driver(params[:id])
    end

    def index
      check_auth
    end

    def new
      check_auth
      build_resource({})
      @cars = Car::available::select([:id, :place_number, :model_name]).all.collect{|p| [p.id, "[#{p.place_number}]    #{p.model_name}"]}
      respond_with self.resource
    end

    def create
      build_resource(params[resource_name])
      if resource.save
        render json: {:status => :ok}# and return if request.xhr?
        #redirect_to admin_driver_index_path
      else
        render json: {:status => :error, :message => resource.errors.messages.to_json}# and return if request.xhr?
        #render :new
      end
    end

    def edit
      check_auth
      driver = resource_class::find params[:id]
      if driver.nil?
        redirect_to admin_driver_index_path
        return
      end
      self.resource = driver
      render  :edit
    end

    def update
      driver = resource_class::find params[:id]
      resource = params[resource_name]

      if driver.nil? || resource.nil?
        render json: {:status => :error, :message => 'invalid resource'}# and return if request.xhr?
        #redirect_to admin_driver_index_path
        return
      end

      if driver.update_attributes(resource)
        render json: {:status => :ok}# and return if request.xhr?
      else
        render json: {:status => :error, :message => driver.errors.messages.to_s}# and return if request.xhr?
      end
      #redirect_to admin_driver_index_path
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
      render json: {:status => :ok} and return if request.xhr?
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
      self.resource = resource_class.new(hash || {})
    end

    def resource_name
      'Driver'
    end

    def resource_class
      Driver
    end

    helper_method :resource, :resource_class, :resource_name
  end
end
