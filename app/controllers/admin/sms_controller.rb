#encoding: utf-8
module Admin
  class SmsController < ApplicationController
    before_filter :authenticate_user!
    layout 'admin'

    def index
      check_auth
      @tab = :sms
      @data = SmsMessage.paginate(:page => params[:page], :per_page => params[:per_page])
    end

    def new
      check_auth
    end

    def create
    end

    def edit
      check_auth
      sms = resource_class::find params[:id]
      redirect_to admin_sms_path and return unless sms
      self.resource = sms
    end

    def update
      sms = resource_class::find params[:id]
      resource = params[resource_name]

      unless sms && resource
        render json:{:status => :error, :message => 'None such sms'} and return if request.xhr?
        redirect_to admin_sms_path and return
      end

      if sms.update_attributes(resource)
        render json:{:status => :ok, :id => sms.id} and return if request.xhr?
      else
        render json:{:status => :error, :message => sms.errors.messages.to_json} and return if request.xhr?
      end
      redirect_to admin_sms_path
    end

    def destroy
      resource_class::find(params[:id]).destroy rescue nil
      redirect_to admin_sms_path
    end

    def show
      sms = resource_class::find params[:id]
      redirect_to admin_sms_path and return unless sms
      self.resource = sms
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
      'sms'
    end

    def resource_class
      SmsMessage
    end

    helper_method :resource, :resource_class, :resource_name
  end
end