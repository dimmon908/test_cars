#encoding: utf-8
module Admin
  class RequestCancelReasonsController < ApplicationController
    before_filter :authenticate_user!
    respond_to :js, :html
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
        redirect_to admin_car_index_path
      else
        respond_with resource
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
      render :edit
    end

    def update
      car = resource_class.find params[:id]
      resource = params[resource_name]
      if car.nil? || resource.nil?
        redirect_to admin_car_index_path
        return
      end
      car.update_attributes(resource)
      redirect_to admin_car_index_path
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
      redirect_to root_path
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
      'reason'
    end

    def resource_class
      RequestCancelReason
    end

    helper_method :resource, :resource_class, :resource_name
  end
end
