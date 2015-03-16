#encoding: utf-8
Test::Application.routes.draw do

  get '/debug', to: 'debug#index'

  post '/referrer', :to => 'referrer#create'

  get '/request/estimate_rate', to: 'request#estimate_rate'
  post '/request/estimate_rate', to: 'request#estimate_rate'

  get '/vehicle/:id', to: 'vehicles#show'
  get '/vehicle', to: 'vehicles#index'

  get 'driver/map', to: 'driver#drivers_map'
  get '/driver/map', to: 'driver#drivers_map'

  get '/user/:id', to: 'users#show'
  get '/user', to: 'users#index'

  #-------------------control card-------------
  get '/card/new', to: 'card#new'
  post '/card/new', to: 'card#create'
  get '/card/:id/edit', to: 'card#edit'
  match '/card/:id', to: 'card#update', :via => [:put, :post]
  get '/card/:id', to: 'card#show'
  delete '/card/:id', to: 'card#delete'
  get '/cards', to: 'card#index'
  #-------------------control card-------------

  #-------------------logs-----------------
  get '/api_logs/', :to => 'logs#api_logs'
  get '/api_logs/clear', :to => 'logs#clear_api_logs'
  get '/api_logs/:type', :to => 'logs#show_api_logs'
  get '/api_log/:id', :to => 'logs#show_api_log'
  delete '/api_log/:id', :to => 'logs#destroy_api_logs'
  get '/logs/clear', to: 'logs#clear'
  resources :logs
  resources :locations
  #-------------------logs-----------------

  #-------------------debug&test-----------
  get '/push', to: 'notification_pull#push'
  get '/push_random', to: 'notification_pull#random'
  get '/email', to: 'notification_pull#email'
  get '/sms', to: 'notification_pull#sms'
  get '/test_sms', to: 'notification_pull#test_sms'
  get '/test', to: 'index#test'
  get '/test/card', to: 'index#test_card'
  get '/test/business', to: 'index#test_business'
  #-------------------debug&test-----------

  #---------------------twillio-------------------------------------
  match '/twillio/sms', to: 'twillio#sms', via: [:get, :post] #twillio callback
  match '/twillio/confirm/:id', to: 'twillio#conf_gratuity', via: [:get, :post] #for test only
  #---------------------twillio-------------------------------------

  #----------------------kiosk api-------------------------------------
  match '/kiosk/request/prepare', to: 'kiosk#prepare_request', via: [:get, :post]
  match '/kiosk/request/create', to: 'kiosk#create_request', via: [:get, :post]
  match '/kiosk/card/add', to: 'kiosk#add_card', via: [:get, :post]
  match '/kiosk/driver/check', to: 'kiosk#check_driver', via: [:get, :post]
  match '/kiosk/driver/info', to: 'kiosk#driver_info', via: [:get, :post]
  match '/kiosk/trip/auth', to: 'kiosk#trip_auth', via: [:get, :post]
  match '/kiosk/trip/test_auth', to: 'kiosk#trip_auth_test', via: [:get, :post]
  match '/kiosk/trip/info', to: 'kiosk#trip_info', via: [:get, :post]
  #----------------------kiosk api-------------------------------------

  #---------------------driver api-------------------------------------
  match '/driver/plate', to: 'driver#plate', via: [:get, :post]
  match '/driver/cars', to: 'driver#cars', via: [:get, :post]
  match '/driver/status', to: 'driver#status', via: [:get, :post]
  match '/driver/location', to: 'driver#location', via: [:get, :post]
  match '/driver/trip', to: 'driver#trip_info', via: [:get, :post]
  match '/driver/trips', to: 'driver#trips', via: [:get, :post]
  match '/driver/trip/accept', to: 'driver#accept_trip', via: [:get, :post]
  match '/driver/arrived', to: 'driver#driver_arrived', via: [:get, :post]
  match '/driver/trip/decline', to: 'driver#decline_trip', via: [:get, :post]
  match '/driver/trip/start', to: 'driver#start_trip', via: [:get, :post]
  match '/driver/trip/edit', to: 'driver#edit_trip', via: [:get, :post]
  match '/driver/trip/cancel', to: 'driver#cancel_trip', via: [:get, :post]
  match '/driver/trip/finish', to: 'driver#finish_trip', via: [:get, :post]
  match '/driver/reason/list', to:'driver#reason_list', via: [:get, :post]
  match '/driver/address/drop', to: 'driver#drop_address', via: [:get, :post]
  match '/driver/gratuity', to: 'driver#gratuity', via: [:get, :post]
  match '/driver/message', to: 'driver#admin_message_response', via: [:get, :post]
  match '/driver/troubles', to: 'driver#troubles', via: [:get, :post]
  #---------------------driver api-------------------------------------

  #---------------------client api-------------------------------------
  match '/client/sign_up', to: 'client#new', via: [:get, :post]
  match '/client/register', to: 'client#register', via: [:get, :post]
  match '/client/card/update', to: 'client#update_credit_card', via: [:get, :post]
  match '/client/card/add', to: 'client#add_credit_card', via: [:get, :post]
  match '/client/location', to: 'client#location', via: [:get, :post]
  match '/client/car/types', to: 'client#car_types', via: [:get, :post]
  match '/client/car/locations', to: 'client#car_locations', via: [:get, :post]
  match '/client/estimated', to: 'client#estimated', via: [:get, :post]
  match '/client/request/start', to: 'client#start_request', via: [:get, :post]
  match '/client/request/cancel', to: 'client#cancel_request', via: [:get, :post]
  match '/client/favorite/add', to: 'client#add_favorite', via: [:get, :post]
  match '/client/favorites', to: 'client#favorites', via: [:get, :post]
  match '/client/photo', to: 'client#set_photo', via: [:post, :put]
  #---------------------client api-------------------------------------

  #---------------------online checkers--------------------------------
  get '/check/email/:value', to: 'check#email'
  get '/check/email/:value/:id', to: 'check#email'
  get '/check/pu', to: 'check#valid_pu'
  get '/check/pu/:lat/:lng', to: 'check#valid_pu'
  get '/check/phone/:value', to: 'check#phone'
  get '/check/phone/:value/:id', to: 'check#phone'
  get '/check/request_status/:value/:user_id/:date', to: 'check#request_status'
  get '/check/request_status_time/:value/:status', to: 'check#request_status_time'
  get '/check/driver_available/:status', to: 'checl#driver_available'
  get '/check/vehicle/:date', to: 'check#future_vehicle'
  get '/check/promo_code_unique/:value', to: 'check#promo_code_unique'
  get '/check/promo_code_unique/:value/:id', to: 'check#promo_code_unique'
  get '/check/promo_name_unique/:value', to: 'check#promo_name_unique'
  get '/check/promo_name_unique/:value/:id', to: 'check#promo_name_unique'
  match '/check/card', to: 'check#valid_credit_card', :via => [:get, :post]
  get '/promo/check/:code', to: 'promo#check'
  get '/promo/check/:code/:user_id', to: 'promo#check'
  #---------------------online checkers--------------------------------

  #---------------------client registration----------------------------
  devise_for :users, controllers: { omniauth_callbacks: 'authentications' }, :path => '', :path_names => { :sign_in => '/login', :sign_out => '/logout' }
  devise_scope :user do
    get '/personal/login', to: 'personal#login'
    get '/business/login', to: 'business#login'
    post '/fb_ios', to: 'devise/sessions#fb_ios'

    post '/personal/login', to: 'devise/sessions#personal'
    post '/business/login', to: 'devise/sessions#business'


    match '/personal/new_account', to: 'personal#create_account', :via => [:get, :post], :defaults => {:format => :json}
    put  '/personal/account/:id', to: 'personal#update_account', :defaults => {:format => :json}

    resources :personal, only: [:new, :create, :edit, :update, :destroy]
    resources :business, only: [:new, :create, :edit, :update, :destroy]
    resources :sub_account, only: [:new, :create, :edit, :update, :destroy, :show]

    get '/password/success', to: 'devise/passwords#success'
    get '/password/fail', to: 'devise/passwords#fail'
    get '/personal', to: 'personal#index'
    get '/personal/success/:id', to: 'personal#success'
    get '/personal/activate/:id', to: 'personal#activate'
    get '/personal/activate_token/:token', to: 'personal#activate_token'

    get '/business', to: 'business#index'
    get '/business/success/:id', to: 'business#success'
    get '/business/activate/:id', to: 'business#activate'
    get '/business/activate/:token', to: 'business#activate_token'

    post '/retrieve_password', to: 'devise/passwords#retrieve_password', :defaults => {:format => :json}

    get '/sub_account', to: 'sub_account#index'

    post '/personal/new', to: 'personal#create'
    post '/personal/activate', to: 'personal#activate!'
    post '/personal/send_activate', to: 'personal#send_activate'

    post '/business/new', to: 'business#create'
    post '/business/activate', to: 'business#activate!'
    post '/business/send_activate', to: 'business#send_activate'

    put '/change_password/:id', to: 'devise/registrations#change_password'
    put '/change_email/:id', to: 'devise/registrations#change_email'
    put '/change_phone/:id', to: 'devise/registrations#change_phone'

    get '/admin', to: 'admin#index'
    match '/admin/users', to: 'admin#users', via: [:get, :delete]
    match '/admin/personal', to: 'admin#personal', via: [:get, :delete]
    match '/admin/business', to: 'admin#business', via: [:get, :delete]
    get '/admin/admins'
    match '/admin/emails', to: 'admin#emails', via: [:get, :delete]
    match '/admin/sms', to: 'admin#sms', via: [:get, :delete]
    match '/admin/notifications', to: 'admin#notifications', via: [:get, :delete]
    get '/admin/dashboard', to: 'admin#dashboard'
    get '/admin/map', to: 'admin#map'
    get '/admin/list', to: 'admin#list'
    match '/admin/car', to: 'admin#car', via: [:get, :delete]
    match '/admin/request', to: 'admin#requests', via: [:get, :delete]
    match '/admin/future_rides', to: 'admin/request#future_rides', via: [:get, :post, :delete]
    match '/admin/driver', to: 'admin#drivers', via: [:get, :delete]

    get '/admin/reports', to: 'admin/reports#daily_report'
    get '/admin/reports/daily', to: 'admin/reports#daily_report'
    get '/admin/reports/future', to: 'admin/reports#future_report'
    get '/admin/reports/driver', to: 'admin/reports#driver_report'
    get '/admin/reports/tips', to: 'admin/reports#tips_report'
    get '/admin/reports/business', to: 'admin/reports#business_report'

    match '/admin/promo_codes', to: 'admin#promo_codes', via: [:get, :delete]
    get '/admin/config_rates', to: 'admin#config_rates'
    get '/admin/config', to: 'admin#configs'
    post '/admin/login', to: 'admin#login'
    get '/admin/password/new', to: 'admin#password'
    post '/admin/password', to: 'admin#reset_password'

    resources :admin, only: [:edit, :update, :new, :create, :destroy]
  end
  match '/admin/login', to: 'index#admin', via: [:get,:post]
  #---------------------client registration----------------------------

  namespace :admin do
    get '/config/group', to: 'config#groups'
    get '/config/group/:name', to: 'config#group'
    put '/config/group/:name', to: 'config#update_group'
    get '/config/list/:name', to: 'config#list'
    get '/config/:id', to: 'config#config_key'
    get '/config/:id/edit', to: 'config#edit'
    put '/config/:id', to: 'config#update'
    post '/config/:id', to: 'config#update'

    match '/vehicle/:id', to: 'config#vehicle', via: [:post, :put]
    get '/vehicle/:id', to: 'config#get_vehicle'
    get '/vehicle/:id/edit', to: 'config#vehicle_edit'
    match '/vehicle/:id/edit', to: 'config#vehicle_update', via: [:post, :put]

    get '/request/finish/:id', to: 'request#finish'
    resources :request, only: [:new, :create, :index, :show, :edit, :update]
    get '/request/reason', to: 'request_cancel_reasons#index'
    get '/request/reason/new', to: 'request_cancel_reasons#new'
    get '/request/reason/:id', to: 'request_cancel_reasons#show'
    get '/request/reason/:id/edit', to: 'request_cancel_reasons#edit'
    match '/request/future_rides', to: 'request#future_rides', via: [:get, :post, :delete]
    post '/request/reason/', to: 'request_cancel_reasons#create'
    put '/request/reason/:id', to: 'request_cancel_reasons#update'
    delete '/request/reason/:id', to: 'request_cancel_reasons#destroy'

    match 'driver/map', via: [:get, :post]
    match '/driver/map', via: [:get, :post]
    match '/driver/message', via: [:get, :post]
    match '/driver/broadcast', via: [:get, :post]
    match '/driver/:id/logoff', to: 'driver#logoff', via: [:get, :post]
    match '/driver/:id/lock/:lock', to: 'driver#lock', via: [:get, :post]
    match '/driver/:id/requests', to: 'driver#requests', via: [:get, :post]

    get '/request/:id/cancel', to: 'request#cancel'
    get '/request/:id/:filter', to: 'request#show'

    get '/pull', to: 'pull#index'
    get '/pull/emails', to: 'pull#emails'
    get '/pull/sms', to: 'pull#sms'
    get '/pull/notifications', to: 'pull#notifications'
    match '/messages', to: 'pull#messages', via: [:get, :post]
    match '/messages/new', to: 'pull#new_messages', via: [:get, :post]
    match '/messages/new/count', to: 'pull#new_messages_count', via: [:get, :post]
    match '/messages/clear_all', to: 'pull#message_clear', via: [:get, :post]
    match '/messages/:id/read', to: 'pull#message_read', via: [:get, :post]
    match '/messages/:id/hide', to: 'pull#message_hide', via: [:get, :post]
    match '/messages/:id/reply', to: 'pull#message_reply', via: [:get, :post]


    get '/business/:id/payment', to: 'payment#new'
    post '/business/:id/payment', to: 'payment#create'

    get '/reports/:id/pdf', to: 'reports#pdf'
    get '/users/:id/limit', to: 'users#limit'
    get '/users/:id/status/:status', to: 'users#status'

    resources :driver, only: [:new, :create, :index, :show, :edit, :update, :destroy]
    resources :car, only: [:new, :create, :index, :show, :edit, :update, :destroy]
    resources :email, only: [:new, :create, :index, :show, :edit, :update, :destroy]
    resources :sms, only: [:new, :create, :index, :show, :edit, :update, :destroy]
    resources :notification, only: [:new, :create, :index, :show, :edit, :update, :destroy]
    resources :request, only: [:new, :create, :index, :show, :edit, :update, :destroy]
    resources :promo_codes, only: [:new, :create, :index, :show, :edit, :update, :destroy]
    resources :passenger, only: [:new, :create, :index, :show, :edit, :update, :destroy]
    resources :company, only: [:new, :create, :index, :show, :edit, :update, :destroy]
    resources :reports, only: [:new, :create, :index, :show, :edit, :update, :destroy]

    resources :personal, only: [:new, :create, :edit, :update, :destroy, :show]
    resources :business, only: [:new, :create, :edit, :update, :destroy, :show]
    resources :users, only: [:new, :create, :edit, :update, :destroy, :show]

  end

  #---------------------------------Request--------------------------------------
  get '/request/confirm/', to: 'request#confirm'
  get '/request/confirm/book/', to: 'request#book_confirm'
  get '/request/confirm/:id', to: 'request#confirm'
  get '/request/edit/book/', to: 'request#book_edit'
  get '/request/confirm/book/:id', to: 'request#book_confirm'
  get '/request/active_list', to: 'request#active_list'
  get '/request/active_list/:id', to: 'request#active_list'
  get '/request/active_request_status', to: 'request#active_request_status'
  get '/request/active_request_status/:id', to: 'request#active_request_status'
  get '/request/past_list', to: 'request#past_list'
  get '/request/last_five/:id', to: 'request#last_five'
  get '/request/next_future/:id', to: 'request#next_future'
  get '/request/new', to: 'request#new'
  get '/request/cancel/:id', to: 'request#cancel'
  get '/request/before_cancel_time/:id', to: 'request#before_cancel_time'
  get '/request/:id', to: 'request#show'
  get '/create_request', to: 'request#get_create_request'
  post '/create_request', to: 'request#create_request'
  post '/mock_create_request', to: 'request#mock_create_request'
  get '/mock_create_request', to: 'request#mock_create_request'
  post '/request/notify', to: 'request#notify'
  post '/request/notify/:id', to: 'request#notify'
  put '/request/update/book/:id', to: 'request#book_update'
  #put '/request/confirm/:id', to: 'request#book'
  post '/request/confirm/', to: 'request#book'
  resources :request, only: [:new, :create, :index, :update, :show]
  #---------------------------------Request--------------------------------------


  #---------------------------------Favorites--------------------------------------
  post '/favorites/exist', to: 'request#in_favorites'
  post '/favorites/add', to: 'request#add_favorites'
  post '/favorites/remove', to: 'request#remove_favorites'
  match '/favorites/list', to: 'request#favorites_list', :via => [:get, :post]
  #---------------------------------Favorites--------------------------------------

  resources :address_book, only: [:new, :create, :index]

  get '/payments/payment'
  get '/payments', :to => 'payments#index'
  get '/payments/select_size', to: 'payments#select_size'
  post '/payments/review_order', :to => 'payments#review'
  post '/payments/payment', :to => 'payments#payment'
  post '/payments/relay_response', :to => 'payments#relay_response'
  get '/payments/receipt', :to => 'payments#receipt'
  get '/payments/error', :to => 'payments#error'

  get '/payments/response', to: 'payments#my_response'
  post '/payments/response', to: 'payments#my_response'

  get '/user', to: 'index#user'
  get '/session/:key', to: 'session#get'
  get '/session/:key/:value', to: 'session#save'
  get '/request/payment/:id', to: 'request#payment'

  root :to => 'index#index'

  match '*unmatched_route', :to => 'application#raise_not_found!'
end
