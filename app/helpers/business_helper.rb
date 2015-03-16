#encoding: utf-8
module BusinessHelper
  NAVIGATION = {
      :dashboard => '/admin/dashboard',
      :requests => '/admin/request/index',
      :future_rides => '/admin/request/index',
      :users => '/admin/sub_accounts/index',
  }

  NAVIGATION_LINKS = {
      :requests => { :name => 'admin.tabs.requests', :action => {:controller => 'admin/request', :action =>  :index}, :tab => :requests, :remote => false, :class => 'glyphicons tags'},
      :future_rides => { :name => 'admin.tabs.future_rides', :action => '/admin/future_rides', :tab => :future_rides, :remote => false, :class => 'glyphicons road'},
      :users => { :name => 'admin.tabs.users', :action => {:controller => '/admin', :action =>  :users}, :tab => :users, :remote => false, :class => 'glyphicons group'}
  }

  NET_TERMS = {
      5 => 'Net 5',
      10 => 'Net 10',
      15 => 'Net 15',
      30 => 'Net 30'
  }
end
