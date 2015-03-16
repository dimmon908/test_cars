class SmsPullController < ApplicationController
  def send
    email = SmsMessagesPull::where(:status => :new).first
    render json: {result: 'no messages in queue'} and return unless email

    if email.send_email
      email.status
    else

    end
  end

  def list
    @list = SmsMessagesPull::where(:status => :new).all
    render json: list
  end
end
