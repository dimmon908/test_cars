class NotificationPullController < ApplicationController
=begin
  def send
    email = NotificationPull::where(:status => :new).first
    render json: {result: 'no notification in queue'} and return unless email

    if email.send_email
      email.status
    else

    end
  end

  def list
    @list = NotificationPull::where(:status => :new).all
    render json: list
  end
=end

  def push
    begin
      Gcm::Notification.send_notifications
      render json: {status: :ok}
    rescue Exception => e
      log_exception e
      render json: {status: :error, :message => e.to_s}
    end

  end

  def random
    begin
      ids = []

      Gcm::Notification.send_notifications Gcm::Notification.order('created_at DESC').group('device_id').all

      Gcm::Notification.order('created_at DESC').group('device_id').all.each do |notify|
        ids << notify.id
      end
      render json: {status: :ok, :id => ids.to_s} and return
    rescue Exception => e
      log_exception e
      render json: {status: :error, :message => e.to_s, :backtrace => e.backtrace.to_s}
    end
  end

  def email

    begin
      render json: {:status => :ok, :result => EmailsPull::deliver}
    rescue Exception => e
      Log.exception e
      render json: {:status => :error, :message => e.to_s}
    end
  end

  def sms
    begin
      render json: {:status => :ok, :result => SmsMessagesPull::deliver}
    rescue Exception => e
      Log.exception e
      render json: {:status => :error, :message => e.to_s}
    end
  end

  def  test_sms
    begin
      res = SmsMessagesPull.new.test_send_sms
      render json: {:status => :ok, :result => res}
    rescue Exception => e
      log_exception e
      render json: {:status => :error, :message => e.to_s}
    end
end

end
