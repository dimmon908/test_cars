#encoding: utf-8
module Admin
  class PullController < ApplicationController
    before_filter :authenticate_user!
    layout 'admin'

    def index
      check_auth
    end

    def emails
      check_auth
      @data = EmailsPull::where(:status => :new).page(params[:page]).all
    end

    def sms
      check_auth
      @data = SmsMessagesPull::where(:status => :new).page(params[:page]).all
    end

    def notifications
      check_auth
      @data = NotificationPull::where(:status => :new).page(params[:page]).all
    end

    def messages
      begin
        data = []
        cnt = Configurations[:admin_display_messages].to_i

        user_id = current_user.id

        query_new = NotificationPull.only_new user_id
        query_new.order('id DESC').each {|notify| data << notify.to_js}

        #readed_count = cnt - query_new.count
        #NotificationPull.readed(current_user.id).order('id DESC').limit(readed_count).each {|notify| data << notify.to_js} if readed_count > 0
        NotificationPull.readed(user_id).order('id DESC').each {|notify| data << notify.to_js}

        resp = {:status => :ok, :data => data}
      rescue Exception => e
        log_exception e
        resp = {:status => :error, :message => e.to_s}
      ensure
        render json: resp
      end
    end

    def new_messages
      begin
        data = []
        NotificationPull::only_new(current_user.id).order('id DESC').each { |notify| data << notify.to_js }
        resp = {:status => :ok, :data => data}
      rescue Exception => e
        resp = {:status => :error, :message => e.to_s}
        log_exception e
      ensure
        render json: resp
      end
    end

    def new_messages_count
      begin
        resp = {:status => :ok, :data => NotificationPull.only_new(current_user.id).count}
      rescue Exception => e
        resp = {:status => :error, :message => e.to_s}
        log_exception e
      ensure
        render json: resp
      end
    end

    def message_read
      begin
        NotificationPull.where(:id => params[:id]).update_all(:status => :readed)
        resp = {:status => :ok}
      rescue Exception => e
        resp = {:status => :error, :message => e.to_s}
        log_exception e
      ensure
        render json: resp
      end
    end

    def message_hide
      begin
        NotificationPull.where(:id => params[:id]).update_all(:status => :hide)
        resp = {:status => :ok}
      rescue Exception => e
        log_exception e
        resp = {:status => :error, :message => e.to_s}
      ensure
        render json: resp
      end
    end

    def message_reply
      begin
        driver_id = NotificationPull.find(params[:id]).params['driver_id']
        driver = Driver::find driver_id
        device = Device.device driver.device_id
        Device.send_notification device, {:data => {:request_type => :reply, :message => params[:message].to_s}}, 'reply'
        resp = {:status => :ok}
      rescue Exception => e
        log_exception e
        resp = {:status => :error, :message => e.to_s}
      ensure
        render json: resp
      end
    end

    def message_clear
      begin
        NotificationPull.visible(current_user.id).update_all(:status => :hide)
        resp = {:status => :ok}
      rescue Exception => e
        log_exception e
        resp = {:status => :error, :message => e.to_s}
      ensure
        render json: resp
      end
    end

  end
end