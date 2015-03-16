#encoding: utf-8
module AdminHelper
  NAVIGATION = {
    :dashboard    => '/admin/dashboard',
    :map          => '/admin/map',
    :requests     => '/admin/request/index',
    :future_rides => '/admin/request/future_rides',
    :passengers   => '/admin/personal',
    :companies    => '/admin/business',
    :drivers      => '/admin/driver/index',
    :cars         => '/admin/car/index',
    :promo_codes  => '/admin/promo_codes/index',
    :admins       => '/admin/admins',
    :report       => '/admin/reports/index',
    :config_rates => '/admin/config/rates',
    :configs      => '/admin/config/group',
    :emails       => '/admin/email/index',
    :sms          => '/admin/sms/index',
    :notification => '/admin/notification/index',
  }

  NAVIGATION_LINKS = {
      #:dashboard => { :name => 'admin.tabs.dashboard', :action => {:controller => 'admin', :action =>  :dashboard}, :tab => :dashboard, :remote => true},
      :map => { :name => 'admin.tabs.map', :action => '/admin/map', :tab => :map, :remote => false, :class => 'glyphicons globe_af'},
      :requests => { :name => 'admin.tabs.requests', :action => '/admin/request', :tab => :requests, :remote => false, :class => 'glyphicons tags'},
      :future_rides => { :name => 'admin.tabs.future_rides', :action => '/admin/future_rides', :tab => :future_rides, :remote => false, :class => 'glyphicons road'},
      :passengers => { :name => 'admin.tabs.passengers', :action => '/admin/personal', :tab => :passengers, :remote => false, :class => 'glyphicons parents'},
      :companies => { :name => 'admin.tabs.companies', :action => '/admin/business', :tab => :companies, :remote => false, :class => 'glyphicons vcard'},
      :drivers => { :name => 'admin.tabs.drivers', :action => '/admin/driver', :tab => :drivers, :remote => false, :class => 'glyphicons user'},
      :cars => { :name => 'admin.tabs.cars', :action => '/admin/car', :tab => :cars, :remote => false, :class => 'glyphicons cars'},
      :users => { :name => 'admin.tabs.users', :action => '/admin/users', :tab => :users, :remote => false, :class => 'glyphicons users'},
      :promo_codes => { :name => 'admin.tabs.promo_codes', :action => '/admin/promo_codes', :tab => :promo_codes, :remote => false, :class => 'glyphicons sampler'},
      :admins => { :name => 'admin.tabs.admins', :action => '/admin/admins', :tab => :admins, :remote => false, :class => 'glyphicons group'},
      :report => { :name => 'admin.tabs.reports', :action =>  '/admin/reports', :tab => :report, :remote => false, :class => 'glyphicons notes_2'},
      :config_rates => { :name => 'admin.tabs.rate_configs', :action => '/admin/config_rates', :tab => :config_rates, :remote => false, :class => 'glyphicons notes_2'},
      :configs => { :name => 'admin.tabs.rates', :action => '/admin/config', :tab => :configs, :remote => false, :class => 'glyphicons notes_2'},
      :emails => { :name => 'admin.tabs.emails', :action => '/admin/email', :tab => :emails, :remote => false, :class => 'glyphicons notes_2'},
      :sms => { :name => 'admin.tabs.sms', :action => '/admin/sms', :tab => :sms, :remote => false, :class => 'glyphicons notes_2'},
      #:notification => { :name => 'admin.tabs.notification', :action => '/admin/notification', :tab => :notification, :remote => false, :class => 'glyphicons notes_2'},
  }

  def push_errors
    return '' unless session[:notice]

    unless session[:notice].is_a?(Hash) || session[:notice].is_a?(Array)
      session[:notice] = nil
      return session[:notice]
    end

    messages = session[:notice].map { |msg| content_tag(:li, msg) }.join

    html = <<-HTML
    <div id="error_explanation">
      <ul>#{messages}</ul>
    </div>
    HTML

    session[:notice] = nil
    html.html_safe
  end
end
