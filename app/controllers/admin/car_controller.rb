#encoding: utf-8
module Admin
  class CarController < ApplicationController
    before_filter :authenticate_user!
    respond_to :js, :html, :json
    layout 'admin'

    def index
      check_auth
    end

    def new
      check_auth
      build_resource({})
      respond_with self.resource
    end

    def create
      build_resource(params[resource_name])
      if resource.save
        render json: {:status => :ok}
        #redirect_to admin_car_index_path
      else
        render json: {:status => :error, :message => resource.errors.messages}
        #respond_with resource
      end
    end

    def edit
      check_auth
      car = resource_class.find params[:id]
      if car.nil?
        redirect_to root_path
        return
      end
      self.resource = car
      render '/admin/car/edit'
    end

    def update
      car = resource_class.find params[:id]
      resource = params[resource_name]
      if car.nil? || resource.nil?
        render json: {:status => :error, :message => 'Invalid request'}
        #redirect_to admin_car_index_path
        return
      end
      if car.update_attributes(resource)
        render json: {:status => :ok}
      else
        render json: {:status => :error, :message => resource.errors.messages}
      end
      #redirect_to admin_car_index_path
    end

    def show
      check_auth
      car = resource_class.find params[:id]
      if car.nil?
        redirect_to root_path
        return
      end
      self.resource = car
    end

    def destroy
      car = resource_class::find params[:id]
      car.destroy
      redirect_to :back
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
      'Car'
    end
    def resource_class
      Car
    end
    helper_method :resource, :resource_class, :resource_name
  end
end
