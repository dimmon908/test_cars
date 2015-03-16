#encoding: utf-8
class TwillioController < ApplicationController
  respond_to :js, :html, :json

  def sms
    begin
      #message_id = params[:MessageSid]
      #account_id = params[:AccountSid]
      from       = params[:From]
      #to         = params[:To]
      body       = params[:Body]
      #num_media  = params[:NumMedia]

      sms_query = SmsMessage::where(:internal_name => :gratuity)
      (resp = {:status => :error, :message => 'No such sms message template'}) and
          return unless sms_query.any?

      push_sms_query = SmsMessagesPull::where(
          :sms_message_id => SmsMessage::find_by_internal_name(:gratuity).id,
          :to             => from,
          :status         => :success
      )

      (resp = {:status => :error, :message => 'No such pushed sms for this number'}) and
          return unless push_sms_query.any?

      #user = push_sms_query.order('created_at DESC').first.user

      request_query = Request::where('phone = ? AND date > ? and date < date', from, Time.yesterday.beginning_of_day, Time.now.end_of_day)

      (resp = {:status => :error, :message => 'No trip for that phone'}) and
          return unless request_query.any?

      trip = request_query.first
      if body.to_s.downcase == '2'
        trip.transaction.gratuity = 0
      elsif body.to_s.downcase == '1'
        trip.transaction.gratuity = trip.transaction.spec_gratuity.to_f
      end
      trip.transaction.full_price
      trip.save :validate => false

      resp = {:status => :ok}
    rescue Exception => e
      resp = {:status => :error, :message => e.to_s}
    ensure
      resp ||= {:status => :error, :message => 'some error'}
      mega_log resp.to_s
      #render :json => resp
      render xml: '<Response/>'
    end
  end

  def conf_gratuity
    begin
      trip = Request.find params[:id] rescue nil
      render json: {:status => :error, :message => 'trip non exist'} and return unless trip

      trip.transaction.gratuity = trip.transaction.spec_gratuity.to_f
      trip.transaction.full_price
      trip.save :validate => false

      render json: {:status => :ok, :message => "gratuity = #{trip.transaction.gratuity}"}
    rescue Exception => e
      render json: {:status => :error, :message => e.to_s}
    end
  end
end
