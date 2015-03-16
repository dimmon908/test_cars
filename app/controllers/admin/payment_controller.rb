class Admin::PaymentController < ApplicationController
  def new
    check_auth

    render :nothing => true, :status => 404 and return unless User::where(:id => params[:id]).any?

    @company = Classes::BusinessAccount::find params[:id]
    build_resource
    self.resource.user_id = params[:id]

    render '/admin/business/payment'
  end

  def create
    build_resource params[:payment]

    if self.resource.save
      render json: {:status => :ok, :id => self.resource.id}
    else
      render json: {:status => :error, :message => self.resource.errors.messages}
    end


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
    self.resource.admin_id ||= current_user.id
  end

  def resource_name
    'payment'
  end

  def resource_class
    Payments
  end

  helper_method :resource, :resource_class, :resource_name
end
