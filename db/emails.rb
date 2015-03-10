#encoding: utf-8
Email::create([:internal_name => :personal_register_confirm, :title => 'Register success', :body_type => :file, :body_template => './app/views/emails/personal/register_success.erb', :desc => "Variables:\n %last_name% - User last name \n %first_name% - User first name \n %email% - User email \n %password% - user password"]) unless Email::where(:internal_name => :personal_register_confirm).any?
Email::create([:internal_name => :business_register_confirm, :title => 'Register success', :body_type => :file, :body_template => './app/views/emails/business/register_success.erb', :desc => "Variables:\n %last_name% - User last name \n %first_name% - User first name \n %email% - User email \n %password% - user password"]) unless Email::where(:internal_name => :business_register_confirm).any?
Email::create([:internal_name => :create_sub_account, :title => 'Register success', :body_type => :file, :body_template => './app/views/emails/sub_account/create.erb', :desc => "Variables:\n %last_name% - User last name \n %first_name% - User first name \n %email% - User email \n %password% - user password"]) unless Email::where(:internal_name => :create_sub_account).any?
Email::create({:internal_name => :get_a_free_ride, :title => 'Get a free ride', :body_type => :file, :body_template => './app/views/emails/referrer/new.erb', :desc => "Variables:\n %last_name% - User last name \n %first_name% - User first name \n %token% - generated token"}) unless Email::where(:internal_name => :get_a_free_ride).any?
Email::create({:internal_name => :send_net_terms, :title => 'Require Net Terms', :body_type => :file, :body_template => './app/views/emails/business/net_terms.erb', :desc => "Variables:\n %last_name% - User last name \n %first_name% - User first name \n %company_name% - company name \n %phone% - Contact Phone number \n %email% - Contact Email"}) unless Email::where(:internal_name => :send_net_terms).any?
#------------------------registered
Email::create({
                  :internal_name => :personal_registered,
                  :title => 'Register success',
                  :body_type => :file,
                  :body_template => './app/views/emails/personal/registered.erb',
                  :desc => "Variables:\n %last_name% - User last name \n %first_name% - User first name \n %username% - User login \n %phone% - User phone"
              }) unless Email::where(:internal_name => :personal_registered).any?
Email::create({
                  :internal_name => :business_registered,
                  :title => 'Register success',
                  :body_type => :file,
                  :body_template => './app/views/emails/business/registered.erb',
                  :desc => "Variables:\n %last_name% - User last name \n %first_name% - User first name \n %email% - User email \n %phone% - User phone \n %company_name% - company name"
              }) unless Email::where(:internal_name => :business_registered).any?
Email::create({
                  :internal_name => :sub_account_registered,
                  :title => 'Register success',
                  :body_type => :file,
                  :body_template => './app/views/emails/sub_account/registered.erb',
                  :desc => "Variables:\n %last_name% - User last name \n %first_name% - User first name \n %email% - User email \n %phone% - User phone \n %company_name% - company name \n %login% - User login \n %password% - user password"
              }) unless Email::where(:internal_name => :sub_account_registered).any?

#-------------------------order created
Email::create({
                  :internal_name => :order_created,
                  :title => 'New request submitted',
                  :body_type => :file,
                  :body_template => './app/views/emails/request/created.erb',
                  :desc => ''
              }) unless Email::where(:internal_name => :order_created).any?

Email::create({
                  :internal_name => :order_created_3rd,
                  :title => 'New request submitted',
                  :body_type => :file,
                  :body_template => './app/views/emails/request/created_3rd.erb',
                  :desc => ''
              }) unless Email::where(:internal_name => :order_created_3rd).any?

#------------------------order accepted
Email::create({
                  :internal_name => :order_accepted,
                  :title => 'Request accepted',
                  :body_type => :file,
                  :body_template => './app/views/emails/request/accepted.erb',
                  :desc => "Variables: \n %from% - PU address \n %eta% - estimates arrived time"
              }) unless Email::where(:internal_name => :order_accepted).any?
Email::create({
                  :internal_name => :order_accepted_3rd,
                  :title => 'Request accepted 3rd',
                  :body_type => :file,
                  :body_template => './app/views/emails/request/accepted_3rd.erb',
                  :desc => "Variables: \n %last_name% - last name \n %first_name% - first name"
              }) unless Email::where(:internal_name => :order_accepted_3rd).any?
Email::create({
                  :internal_name => :order_accepted_friend,
                  :title => 'Request accepted – booked for a guest or friend',
                  :body_type => :file,
                  :body_template => './app/views/emails/request/accepted_friend.erb',
                  :desc => "Variables: \n %last_name% - last name \n %first_name% - first name"
              }) unless Email::where(:internal_name => :order_accepted_friend).any?
Email::create({
                  :internal_name => :order_accepted_friend_3rd,
                  :title => 'Request accepted – booked for a guest or friend 3rd',
                  :body_type => :file,
                  :body_template => './app/views/emails/request/accepted_friend_3rd.erb',
                  :desc => "Variables: \n %last_name% - last name \n %first_name% - first name"
              }) unless Email::where(:internal_name => :order_accepted_friend_3rd).any?

#------------------------order declined
Email::create({
                  :internal_name => :order_declined,
                  :title => 'Request declined',
                  :body_type => :file,
                  :body_template => './app/views/emails/request/declined.erb',
                  :desc => ''
              }) unless Email::where(:internal_name => :order_declined).any?
Email::create({
                  :internal_name => :order_declined_friend,
                  :title => 'Request declined for a guest',
                  :body_type => :file,
                  :body_template => './app/views/emails/request/declined_friend.erb',
                  :desc => ''
              }) unless Email::where(:internal_name => :order_declined_friend).any?

#------------------------order arrived
Email::create({
                  :internal_name => :order_arrived,
                  :title => 'Driver Arrived to PU',
                  :body_type => :file,
                  :body_template => './app/views/emails/request/arrived.erb',
                  :desc => ''
              }) unless Email::where(:internal_name => :order_arrived).any?
Email::create({
                  :internal_name => :order_arrived_3rd,
                  :title => 'Driver Arrived to PU - 3rd',
                  :body_type => :file,
                  :body_template => './app/views/emails/request/arrived_3rd.erb',
                  :desc => ''
              }) unless Email::where(:internal_name => :order_arrived_3rd).any?
Email::create({
                  :internal_name => :order_arrived_friend,
                  :title => 'Driver Arrived to PU for guest',
                  :body_type => :file,
                  :body_template => './app/views/emails/request/arrived_friend.erb',
                  :desc => ''
              }) unless Email::where(:internal_name => :order_arrived_friend).any?
Email::create({
                  :internal_name => :order_arrived_friend_3rd,
                  :title => 'Driver Arrived to PU for guest - 3rd',
                  :body_type => :file,
                  :body_template => './app/views/emails/request/arrived_friend_3rd.erb',
                  :desc => ''
              }) unless Email::where(:internal_name => :order_arrived_friend_3rd).any?

#------------------------order picked_up
Email::create({
                  :internal_name => :order_picked_up_3rd,
                  :title => 'Driver picked up passenger - 3rd',
                  :body_type => :file,
                  :body_template => './app/views/emails/request/picked_up_3rd.erb',
                  :desc => ''
              }) unless Email::where(:internal_name => :order_picked_up_3rd).any?
Email::create({
                  :internal_name => :order_picked_up_friend,
                  :title => 'Driver picked up passenger-guest',
                  :body_type => :file,
                  :body_template => './app/views/emails/request/picked_up_friend.erb',
                  :desc => ''
              }) unless Email::where(:internal_name => :order_picked_up_friend).any?
Email::create({
                  :internal_name => :order_picked_up_friend_3rd,
                  :title => 'Driver picked up passenger-guest - 3rd',
                  :body_type => :file,
                  :body_template => './app/views/emails/request/picked_up_friend_3rd.erb',
                  :desc => ''
              }) unless Email::where(:internal_name => :order_picked_up_friend_3rd).any?

#------------------------order finished
Email::create({
                  :internal_name => :order_finished,
                  :title => 'Trip ended at DO',
                  :body_type => :file,
                  :body_template => './app/views/emails/request/finish.erb',
                  :desc => ''
              }) unless Email::where(:internal_name => :order_finished).any?
Email::create({
                  :internal_name => :order_finished_3rd,
                  :title => 'Trip ended at DO - 3rd',
                  :body_type => :file,
                  :body_template => './app/views/emails/request/finish_3rd.erb',
                  :desc => ''
              }) unless Email::where(:internal_name => :order_finished_3rd).any?
Email::create({
                  :internal_name => :order_finished_friend,
                  :title => 'Trip ended at DO for guest',
                  :body_type => :file,
                  :body_template => './app/views/emails/request/finish_friend.erb',
                  :desc => ''
              }) unless Email::where(:internal_name => :order_finished_friend).any?
Email::create({
                  :internal_name => :order_finished_friend_3rd,
                  :title => 'Trip ended at DO for guest - 3rd',
                  :body_type => :file,
                  :body_template => './app/views/emails/request/finish_friend_3rd.erb',
                  :desc => ''
              }) unless Email::where(:internal_name => :order_finished_friend_3rd).any?

#------------------------order canceled
Email::create({
                  :internal_name => :order_canceled,
                  :title => 'Request Canceled',
                  :body_type => :file,
                  :body_template => './app/views/emails/request/cancel.erb',
                  :desc => ''
              }) unless Email::where(:internal_name => :order_canceled).any?
Email::create({
                  :internal_name => :order_canceled_3rd,
                  :title => 'Request Canceled - 3rd',
                  :body_type => :file,
                  :body_template => './app/views/emails/request/cancel_3rd.erb',
                  :desc => ''
              }) unless Email::where(:internal_name => :order_canceled_3rd).any?

#------------------------account changes
Email::create({
                  :internal_name => :cc_change,
                  :title => 'User Credit Card Change',
                  :body_type => :file,
                  :body_template => './app/views/emails/personal/change_credit_card.erb',
                  :desc => ''
              }) unless Email::where(:internal_name => :cc_change).any?
Email::create({
                  :internal_name => :email_change,
                  :title => 'User email changed',
                  :body_type => :file,
                  :body_template => './app/views/emails/personal/change_email.erb',
                  :desc => ''
              }) unless Email::where(:internal_name => :email_change).any?
Email::create({
                  :internal_name => :password_change,
                  :title => 'User password changed',
                  :body_type => :file,
                  :body_template => './app/views/emails/personal/change_password.erb',
                  :desc => ''
              }) unless Email::where(:internal_name => :password_change).any?

#------------------------cc reminders
Email::create({
                  :internal_name => :card_reminder_30,
                  :title => 'Remind credit card 30 days before expire',
                  :body_type => :text,
                  :body_template => 'Dear %last_name% %first_name%, your credit card %card% will be expired after 30 days',
                  :desc => ''
              }) unless Email::where(:internal_name => :card_reminder_30).any?
Email::create({
                  :internal_name => :card_reminder_15,
                  :title => 'Remind credit card 15 days before expire',
                  :body_type => :text,
                  :body_template => 'Dear %last_name% %first_name%, your credit card %card% will be expired after 15 days',
                  :desc => ''
              }) unless Email::where(:internal_name => :card_reminder_15).any?
Email::create({
                  :internal_name => :card_reminder_3,
                  :title => 'Remind credit card 3 days before expire',
                  :body_type => :text,
                  :body_template => 'Dear %last_name% %first_name%, your credit card %card% will be expired after 3 days',
                  :desc => ''
              }) unless Email::where(:internal_name => :card_reminder_3).any?
Email::create({
                  :internal_name => :card_reminder_1,
                  :title => 'Remind credit card 1 day before expire',
                  :body_type => :text,
                  :body_template => 'Dear %last_name% %first_name%, your credit card %card% will be expired tomorrow',
                  :desc => ''
              }) unless Email::where(:internal_name => :card_reminder_1).any?

#------------------------credit reminders
Email::create({
                  :internal_name => :credit_reminder_20,
                  :title => 'Available credit line - 20%',
                  :body_type => :text,
                  :body_template => 'Dear %last_name% %first_name%, your credit line near the 20%',
                  :desc => ''
              }) unless Email::where(:internal_name => :credit_reminder_20).any?
Email::create({
                  :internal_name => :credit_reminder_10,
                  :title => 'Available credit line - 10%',
                  :body_type => :text,
                  :body_template => 'Dear %last_name% %first_name%, your credit line near the 10%',
                  :desc => ''
              }) unless Email::where(:internal_name => :credit_reminder_10).any?
Email::create({
                  :internal_name => :credit_reminder_5,
                  :title => 'Available credit line - 5%',
                  :body_type => :text,
                  :body_template => 'Dear %last_name% %first_name%, your credit line near the 5%',
                  :desc => ''
              }) unless Email::where(:internal_name => :credit_reminder_5).any?