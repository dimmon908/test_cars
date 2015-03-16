#encoding: utf-8
module Admin
  class NotificationController < ApplicationController
    before_filter :authenticate_user!
    layout 'admin'

    def index
      check_auth
      @tab = :notification
      @data = Notification.paginate(:page => params[:page], :per_page => params[:per_page]).all
    end

    def new
      check_auth
    end

    def create

    end

    def edit
      check_auth
      notification = resource_class::find params[:id]
      redirect_to admin_notification_index_path and return unless notification
      self.resource = notification
    end

    def update
      notification = resource_class::find params[:id]
      resource = params[resource_name]

      unless notification && resource
        render json:{:status => :error, :message => 'None such notification'} and return if request.xhr?
        redirect_to admin_notification_index_path and return
      end

      if notification.update_attributes(resource)
        render json:{:status => :ok, :id => notification.id} and return if request.xhr?
      else
        render json:{:status => :error, :message => notification.errors.messages.to_json} and return if request.xhr?
      end
      redirect_to admin_notification_index_path
    end

    def destroy
      resource_class::find(params[:id]).destroy rescue nil
      redirect_to admin_notification_index_path
    end

    def show
      notification = resource_class::find params[:id]
      redirect_to admin_notification_index_path and return unless notification
      self.resource = notification
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
      'notification'
    end

    def resource_class
      Notification
    end

    helper_method :resource, :resource_class, :resource_name
  end
end