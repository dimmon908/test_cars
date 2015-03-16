begin
  SendPushNotifications::start_me_up
rescue Exception => e
  Log::exception e
end

begin
  SendEmailNotifications::start_me_up
rescue Exception => e
  Log::exception e
end

begin
  SendSmsNotifications::start_me_up
rescue Exception => e
  Log::exception e
end

begin
  Reminders::ExpireCc::start_me
rescue Exception => e
  Log::exception e
end

begin
  Reminders::CreditLimit::start_me
rescue Exception => e
  Log::exception e
end

begin
  CheckRequestJob::start_me_up
rescue Exception => e
  Log::exception e
end

begin
  CheckFutureJob::start_me_up
rescue Exception => e
  Log::exception e
end

begin
  CheckLogsJob.start_me_up
rescue Exception => e
  Log::exception e
end

begin
  CheckOnlineJob.start_me_up
rescue Exception => e
  Log::exception e
end

begin
  require './app/models/inits/check_c_c'
  Inits::CheckCC.start_me_up
rescue Exception => e
  Log::exception e
end

begin
  CheckDriversAccount.start_me_up
rescue Exception => e
  Log::exception e
end