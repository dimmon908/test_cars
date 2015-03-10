#encoding: utf-8
class ApplicationController < ActionController::Base
  before_filter :setup_mcapi

  protect_from_forgery
  rescue_from CanCan::AccessDenied do |exception|
    session[:link] = request.original_url
    log_exception exception
    redirect_to '/admin/login', :alert => exception.message
  end

  #unless Rails.application.config.consider_all_requests_local
  #  rescue_from Exception, :with => :render_error
  #  rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
  #  rescue_from ActionController::RoutingError, :with => :render_not_found
  #end

  #called by last route matching unmatched routes.  Raises RoutingError which will be rescued from in the same way as other exceptions.
  def raise_not_found!
    e = ActionController::RoutingError.new("No route matches #{params[:unmatched_route]}")
    log_exception e
    raise e
  end

  #render 500 error
  def render_error(e)
    respond_to do |f|
      f.html { render :template => 'errors/500', :status => 500 }
      f.js { render :partial => 'errors/ajax_500', :status => 500 }
      f.json { render :json => {:status => :error, :message => 'render error'}, :status => 500 }
    end
  end

  #render 404 error
  def render_not_found(e)
    respond_to do |f|
      f.html { render :template => 'errors/404', :status => 404 }
      f.js { render :partial => 'errors/ajax_404', :status => 404 }
      f.json { render :json => {:status => :error, :message => 'render not found'}, :status => 404 }
    end
  end


  protected
  def log_exception(e)
    user = nil
    user = current_user if user_signed_in?
    data = ''
    data = ({:exception => e.to_s, :backtrace => e.backtrace.to_s}).to_json.to_s if e

    Log::create({
                    :data        => data,
                    :log_type    => :error,
                    :user        => user,
                    :request_url => request.fullpath.to_s,
                    :request     => request.to_s,
                    :session     => session.to_s,
                    :params      => params.to_s
                }) rescue nil

  end

  def mega_log(data)
    user = nil
    user = current_user if user_signed_in?

    Log::create({
                    :data        => ({:data => data.to_s}).to_json.to_s,
                    :log_type    => :notice,
                    :user        => user,
                    :request_url => request.fullpath.to_s,
                    :request     => request.to_s,
                    :session     => session.to_s,
                    :params      => params.to_s
                }) rescue nil
  end

  def setup_mcapi
    @mc = Mailchimp::API.new('f20bcdef00a949c5c120034fd5dcad13-us3') # my local api key
  end

  def check_auth(ability = :admin, rights = current_user)
    raise CanCan::AccessDenied unless current_user
    raise CanCan::AccessDenied unless user_signed_in?
    raise CanCan::AccessDenied unless can? ability, rights
  end
end
