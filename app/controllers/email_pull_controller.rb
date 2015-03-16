class EmailPullController < ApplicationController
  def send
    email = EmailsPull::where(:status => :new).first
    render json: {result: 'no emails in queue'} and return unless email

    if email.send_email
      email.status
    else

    end
  end

  def list
    @list = EmailsPull::where(:status => :new).all
    render json: list
  end
end
