#encoding: utf-8
#Notification
Notification::create({
                         :internal_name => :none_money,
                         :title => 'Not enough money',
                         :body_type => :file,
                         :body_template => './app/views/notifications/client/card.erb',
                         :desc => "Variables:\n%card_number% - Carn number"
                     }) unless Notification::where(:internal_name => :none_money).any?

Notification::create({
                         :internal_name => :delayed_car_trouble,
                         :title => 'Delayed - Car trouble',
                         :body_type => :file,
                         :body_template => './app/views/notifications/driver/delayed_car_trouble.erb',
                         :desc => "Variables:\n%time% - time of notification \n %driver% - driver full name"
                     }) unless Notification::where(:internal_name => :delayed_car_trouble).any?

Notification::create({
                         :internal_name => :delayed_traffic,
                         :title => 'Delayed - Traffic',
                         :body_type => :file,
                         :body_template => './app/views/notifications/driver/delayed_traffic.erb',
                         :desc => "Variables:\n%time% - time of notification \n %driver% - driver full name"
                     }) unless Notification::where(:internal_name => :delayed_traffic).any?

Notification::create({
                         :internal_name => :ack,
                         :title => 'On my way back',
                         :body_type => :file,
                         :body_template => './app/views/notifications/driver/back.erb',
                         :desc => "Variables:\n%time% - time of notification \n %driver% - driver full name"
                     }) unless Notification::where(:internal_name => :iback).any?

Notification::create({
                         :internal_name => :unable_accept_car_trouble,
                         :title => 'Unable to accept requests - Car trouble',
                         :body_type => :file,
                         :body_template => './app/views/notifications/driver/unable_accept_car_trouble.erb',
                         :desc => "Variables:\n%time% - time of notification \n %driver% - driver full name"
                     }) unless Notification::where(:internal_name => :unable_accept_car_trouble).any?