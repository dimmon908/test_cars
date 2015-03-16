#encoding: utf-8
#-------------------------activate
SmsMessage::create({
                       :internal_name => :personal_activate,
                       :title => 'Activate account',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/personal/activate.erb',
                       :desc => "Variables:\n%last_name% - User last name \n %first_name% - User first name\n%activate_code% - activate code for account\n%link%"
                   }) unless SmsMessage::where(:internal_name => :personal_activate).any?
SmsMessage::create({
                       :internal_name => :business_activate,
                       :title => 'Activate account',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/business/activate.erb',
                       :desc => "Variables:\n%last_name% - User last name \n %first_name% - User first name\n%activate_code% - activate code for account\n%link%"
                   }) unless SmsMessage::where(:internal_name => :business_activate).any?

#-------------------------order created
SmsMessage::create({
                       :internal_name => :order_created,
                       :title => 'New request submitted',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/request/created.erb',
                       :desc => ''
                   }) unless SmsMessage::where(:internal_name => :order_created).any?
SmsMessage::create({
                       :internal_name => :order_created_3rd,
                       :title => 'New request submitted',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/request/created_3rd.erb',
                       :desc => ''
                   }) unless SmsMessage::where(:internal_name => :order_created_3rd).any?

#-------------------------order accepted
SmsMessage::create({
                       :internal_name => :order_accepted,
                       :title => 'Request accepted',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/request/accepted.erb',
                       :desc => "Variables: \n %from% - PU address \n %eta% - estimates arrived time"
                   }) unless SmsMessage::where(:internal_name => :order_accepted).any?
SmsMessage::create({
                       :internal_name => :order_accepted_friend,
                       :title => 'Request accepted – booked for a guest or friend',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/request/accepted_friend.erb',
                       :desc => ''
                   }) unless SmsMessage::where(:internal_name => :order_accepted_friend).any?
SmsMessage::create({
                       :internal_name => :order_accepted_friend_3rd,
                       :title => 'Request accepted – booked for a guest or friend 3rd',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/request/accepted_friend_3rd.erb',
                       :desc => ''
                   }) unless SmsMessage::where(:internal_name => :order_accepted_friend).any?
SmsMessage::create({
                       :internal_name => :order_accepted_3rd,
                       :title => 'Request accepted - 3rd',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/request/accepted_3rd.erb',
                       :desc => "Variables: \n %last_name% - last name \n %first_name% - first name"
                   }) unless SmsMessage::where(:internal_name => :order_accepted_3rd).any?

#-------------------------order declined
SmsMessage::create({
                       :internal_name => :order_declined,
                       :title => 'Request declined',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/request/declined.erb',
                       :desc => ''
                   }) unless SmsMessage::where(:internal_name => :order_declined).any?
SmsMessage::create({
                       :internal_name => :order_declined_friend,
                       :title => 'Request declined for a guest',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/request/declined_friend.erb',
                       :desc => ''
                   }) unless SmsMessage::where(:internal_name => :order_declined_friend).any?

#-------------------------order arrived
SmsMessage::create({
                       :internal_name => :order_arrived,
                       :title => 'Driver Arrived to PU',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/request/arrived.erb',
                       :desc => ''
                   }) unless SmsMessage::where(:internal_name => :order_arrived).any?
SmsMessage::create({
                       :internal_name => :order_arrived_3rd,
                       :title => 'Driver Arrived to PU 3rd',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/request/arrived_3rd.erb',
                       :desc => ''
                   }) unless SmsMessage::where(:internal_name => :order_arrived_3rd).any?
SmsMessage::create({
                       :internal_name => :order_arrived_friend,
                       :title => 'Driver Arrived to PU for guest',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/request/arrived_friend.erb',
                       :desc => ''
                   }) unless SmsMessage::where(:internal_name => :order_arrived_friend).any?
SmsMessage::create({
                       :internal_name => :order_arrived_friend_3rd,
                       :title => 'Driver Arrived to PU for guest - 3rd',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/request/arrived_friend_3rd.erb',
                       :desc => ''
                   }) unless SmsMessage::where(:internal_name => :order_arrived_friend_3rd).any?

#------------------------order picked_up
SmsMessage::create({
                  :internal_name => :order_picked_up_3rd,
                  :title => 'Driver picked up passenger - 3rd',
                  :body_type => :file,
                  :body_template => './app/views/sms_messages/request/picked_up_3rd.erb',
                  :desc => ''
              }) unless SmsMessage::where(:internal_name => :order_picked_up_3rd).any?
SmsMessage::create({
                  :internal_name => :order_picked_up_friend,
                  :title => 'Driver picked up passenger-guest',
                  :body_type => :file,
                  :body_template => './app/views/sms_messages/request/picked_up_friend.erb',
                  :desc => ''
              }) unless SmsMessage::where(:internal_name => :order_picked_up_friend).any?
SmsMessage::create({
                  :internal_name => :order_picked_up_friend_3rd,
                  :title => 'Driver picked up passenger-guest - 3rd',
                  :body_type => :file,
                  :body_template => './app/views/sms_messages/request/picked_up_friend_3rd.erb',
                  :desc => ''
              }) unless SmsMessage::where(:internal_name => :order_picked_up_friend_3rd).any?

#------------------------order finished
SmsMessage::create({
                  :internal_name => :order_finished,
                  :title => 'Trip ended at DO',
                  :body_type => :file,
                  :body_template => './app/views/sms_messages/request/finish.erb',
                  :desc => ''
              }) unless SmsMessage::where(:internal_name => :order_finished).any?
SmsMessage::create({
                  :internal_name => :order_finished_3rd,
                  :title => 'Trip ended at DO - 3rd',
                  :body_type => :file,
                  :body_template => './app/views/sms_messages/request/finish_3rd.erb',
                  :desc => ''
              }) unless SmsMessage::where(:internal_name => :order_finished_3rd).any?
SmsMessage::create({
                  :internal_name => :order_finished_friend,
                  :title => 'Trip ended at DO for guest',
                  :body_type => :file,
                  :body_template => './app/views/sms_messages/request/finish_friend.erb',
                  :desc => ''
              }) unless SmsMessage::where(:internal_name => :order_finished_friend).any?
SmsMessage::create({
                  :internal_name => :order_finished_friend_3rd,
                  :title => 'Trip ended at DO for guest - 3rd',
                  :body_type => :file,
                  :body_template => './app/views/sms_messages/request/finish_friend_3rd.erb',
                  :desc => ''
              }) unless SmsMessage::where(:internal_name => :order_finished_friend_3rd).any?

#-------------------------order cancel
SmsMessage::create({
                       :internal_name => :order_canceled,
                       :title => 'Request Canceled',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/request/cancel.erb',
                       :desc => ''
                   }) unless SmsMessage::where(:internal_name => :order_canceled).any?
SmsMessage::create({
                       :internal_name => :order_canceled_3rd,
                       :title => 'Request Canceled 3rd',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/request/cancel_3rd.erb',
                       :desc => ''
                   }) unless SmsMessage::where(:internal_name => :order_canceled_3rd).any?

#-------------------------registered
SmsMessage::create({
                       :internal_name => :personal_registered,
                       :title => 'Personal user completed the sign-up process',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/personal/registered.erb',
                       :desc => ''
                   }) unless SmsMessage::where(:internal_name => :personal_registered).any?
SmsMessage::create({
                       :internal_name => :business_registered,
                       :title => 'Business user completed the sign-up process',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/business/registered.erb',
                       :desc => ''
                   }) unless SmsMessage::where(:internal_name => :business_registered).any?
SmsMessage::create({
                       :internal_name => :cc_change,
                       :title => 'User Credit Card Change',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/personal/change_credit_card.erb',
                       :desc => ''
                   })  unless SmsMessage::where(:internal_name => :cc_change).any?
SmsMessage::create({
                       :internal_name => :email_change,
                       :title => 'User email changed',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/personal/change_email.erb',
                       :desc => ''
                   })  unless SmsMessage::where(:internal_name => :email_change).any?
SmsMessage::create({
                       :internal_name => :password_change,
                       :title => 'User password changed',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/personal/change_password.erb',
                       :desc => ''
                   })  unless SmsMessage::where(:internal_name => :password_change).any?

SmsMessage::create({
                       :internal_name => :forgot_password,
                       :title => 'User forgot the password',
                       :body_type => :file,
                       :body_template => './app/views/devise/sms/reset_password_instructions.html.erb',
                       :desc => ''
                   }) unless SmsMessage::where(:internal_name => :forgot_password).any?
SmsMessage::create({
                      :internal_name => :trip_started,
                      :title => 'Trip - started',
                      :body_type => :text,
                      :body_template => 'Your request for a comfortable luxurious ride has been accepted and your chauffeur is on the way. You can track their progress to you on your mobile device or desktop',
                      :desc => ''
                   }) unless SmsMessage::where(:internal_name => :trip_started).any?
SmsMessage::create({
                      :internal_name => :declined_trip,
                      :title => 'Trip - declined',
                      :body_type => :text,
                      :body_template => 'We want to apologize that no Сhauffeurs were available at this time to accept your request. We are working to find more chauffeurs who meet our standards.',
                      :desc => ''
                   }) unless SmsMessage::where(:internal_name => :declined_trip).any?
SmsMessage::create({
                      :internal_name => :cancelled_trip,
                      :title => 'Trip - cancelled',
                      :body_type => :text,
                      :body_template => 'Your request is now cancelled. We look forward to serving you in the future.',
                      :desc => ''
                   }) unless SmsMessage::where(:internal_name => :cancelled_trip).any?
SmsMessage::create({
                       :internal_name => :future_trip,
                       :title => 'Trip - Future',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/request/future.erb',
                       :desc => ''
                   }) unless SmsMessage::where(:internal_name => :finished_trip).any?
SmsMessage::create({
                      :internal_name => :finished_trip,
                      :title => 'Trip - finished',
                      :body_type => :text,
                      :body_template => 'We have enjoyed serving you and getting you comfortably nd safely to your destination. If you requested, an email receipt is being sent to you',
                      :desc => ''
                   }) unless SmsMessage::where(:internal_name => :finished_trip).any?

SmsMessage::create({
                       :internal_name => :gratuity,
                       :title => 'Trip - gratuity',
                       :body_type => :file,
                       :body_template => './app/views/sms_messages/request/gratuity.erb',
                       :desc => ''
                   }) unless SmsMessage::where(:internal_name => :gratuity).any?
SmsMessage::create({
                       :internal_name => :future_request_not_responded_to,
                       :title => 'Future Trip - No drivers responded to future request',
                       :body_type => :file,
                       :body_template => 'No drivers have responded to the future request %request_id% of %user_first_name% %user_last_name% within response time window of %response_time_window% before future request time %request_date% from %from%',
                       :desc => ''
                   }) unless SmsMessage::where(:internal_name => :future_request_not_responded_to).any?


SmsMessage::create({
                      :internal_name => :notify_admin_future,
                      :title => 'Future trip not accepted',
                      :body_type => :file,
                      :body_template => './app/views/sms_messages/request/notify_admin_future.erb',
                      :desc => ''
                   }) unless SmsMessage::where(:internal_name => :notify_admin_future).any?