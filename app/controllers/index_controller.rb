#encoding: utf-8
class IndexController < ApplicationController
  layout 'main'
  def index
    if user_signed_in?
      if current_user.role? :admin
        redirect_to '/admin'
      else
        redirect_to request_index_path
      end
    else
      #redirect_to new_user_registration_path
    end
  end

  def new
  end

  def show
  end

  def user
    if user_signed_in?
      redirect_to "/#{current_user.base_url}"
    else
      redirect_to root_path
    end
  end

  def admin
    render file: '/admin/login', :layout => 'admin_login'
  end

  def test
    #begin
    #  trip = Request.find 1172
    #  res = trip.pre_payment
    #  trip.void if res
    #  render json: {:status => :ok, :result => res}
    #rescue Exception => e
    #  render json: {:status => :error, :message => e.to_s}
    #end
    #return


    time = Time.now
    begin
      #Reminders::ExpireCc.new.remind(9000, :card_reminder_30)
      #Reminders::CreditLimit.new.remind(1, 0.1, :credit_reminder_20)
      APN::Device.all.each { |dev| Device::send_notification dev, {:comment => 'test comment', :data => {:comment => 'test comment'}}, 'test comment' }
      #SendPushNotifications::start_me_up
      resp = {:status => :ok}
    rescue Exception => e
      resp = {:status => :error, :message => e.to_s, :backtrace => e.backtrace.to_s}
    ensure
      resp[:time] = Time.now - time
      render json: resp
    end
  end

  def test_card
    begin
      card_number = "4111111111111111"
      card_date = "0115"
      card_cvv = "111"

      card = ::AuthorizeNet::CreditCard.new(card_number, card_date, :card_code =>  card_cvv)
      bill = Payment::AuthorizeNet.new
      response = bill.check card

      if response.success?
        bill.check_void response.transaction_id
        render json: {:status => :ok, :transaction_id => response.transaction_id}
      else
        render json: {:status => :error, :message => response.response_reason_text}
      end

    rescue Exception => e
      render json: {:status => :error, :message => e.to_s}
    end
  end

  def test_business
    begin
      user = Classes::BusinessAccount.find 49
      user.business_info
      render json: {:user => user, :business => user.business_info, :info => user.user_profile, :role => user.role}
    rescue => e
      render json: {:status => :error, :message => e.to_s}
    end
  end

end
