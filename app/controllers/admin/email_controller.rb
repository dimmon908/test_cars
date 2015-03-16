#encoding: utf-8
module Admin
  class EmailController < ApplicationController
    before_filter :authenticate_user!
    layout 'admin'

    def index
      check_auth
      @tab = :emails
      @data = Email.paginate(:page => params[:page], :per_page => params[:per_page])
    end

    def new
      check_auth
    end

    def create
    end

    def edit
      check_auth
      email = resource_class::find params[:id]
      redirect_to admin_email_index_path and return unless email
      self.resource = email
      render :layout => false if request.xhr?
    end

    def update
      email = resource_class::find params[:id]
      resource = params[resource_name]

      unless email && resource
        render json:{:status => :error, :message => 'None such email'} and return if request.xhr?
        redirect_to admin_email_index_path and return
      end


      if email.update_attributes(resource)
        render json:{:status => :ok, :id => email.id} and return if request.xhr?
      else
        render json:{:status => :error, :message => email.errors.messages.to_json} and return if request.xhr?
      end
      redirect_to admin_email_index_path
    end

    def destroy
      resource_class::find(params[:id]).destroy rescue nil
      redirect_to admin_email_index_path
    end

    def show
      check_auth
      email = resource_class::find params[:id]
      redirect_to admin_email_index_path and return unless email
      self.resource = email
      render :layout => false if request.xhr?
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
      'email'
    end

    def resource_class
      Email
    end

    helper_method :resource, :resource_class, :resource_name
  end
end