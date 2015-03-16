class DebugController < ApplicationController
  before_filter :authenticate_user!
  respond_to :js, :html
  layout 'admin'


  def index
  end
end
