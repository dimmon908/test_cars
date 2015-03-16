class ReferrerController < ApplicationController
  before_filter :authenticate_user!
  respond_to :js, :html, :json

  # POST
  def create
    begin
      message = {}

      if params[:referrer] && params[:referrer]['email']

        params[:referrer]['email'].each do |email|

          message[email[0]] = t('model.errors.custom.invalid_referrer_email') and next unless email[1].to_s =~ User::EMAIL_REGEXP
          #message[email[0]] = t('model.errors.custom.user_exist') and next if User::where(:email => email[1]).any?

          Referrer::create({:email => email[1], :user => current_user})
        end

      end
      render json: {:status => :ok, :message => message}

    rescue Exception => e
      log_exception e
      render json: {:status => :error, :message => e.to_s}
    end
  end
end
