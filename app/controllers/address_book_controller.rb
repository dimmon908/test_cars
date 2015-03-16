#encoding: utf-8
class AddressBookController < ApplicationController
  before_filter :authenticate_user!
  set_tab :address_book
  layout 'main'
  respond_to :js, :html, :json

  def show

  end

  def index
    @list = AddressBook::where(:user_id => current_user.id, :show => 1)
    #@list = Favorites::where(:user_id => current_user.id)
  end

  def create
    build_resource(params[resource_name])
    if resource.save
      redirect_to address_book_index_path
    else
      respond_with resource
    end
  end

  def new
    build_resource({})
    respond_with self.resource
  end

  def edit

  end

  def update

  end

  def destroy

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
    resource.user_id ||= current_user.id
    resource.show ||= 1
  end

  def resource_name
    'AddressBook'
  end

  def resource_class
    AddressBook
  end

  helper_method :resource, :resource_class, :resource_name
end
