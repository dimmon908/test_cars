#encoding: utf-8
class SmsMessagesPull < ActiveRecord::Base
  scope :for_send, -> {where(:status => :new)}
  serialize :params
  belongs_to :sms_message
  belongs_to :user
  attr_accessible :fail_stamp, :params, :status, :success_stamp, :sms_message, :sms_message_id, :user, :user_id, :to

  before_save :before_save
  after_initialize :after_init

  include Included::Deliver
  extend Excluded::Deliver

  def get_to
    to = self.to unless self.to.blank?
    to ||= user.phone

    to.gsub!(/\-\+ /, '')
    "+#{to}"
  end

  def process
      to = get_to
      full_body = sms_message.body_with_params(params)

      (full_body.length.to_f/160).ceil.times do |index|
        client.account.sms.messages.create(
            :body => full_body[index*160, 160],
          :to => to,
          :from => Configurations[:twilio_from_number]
      )
    end
      true
    end

  def test_send_sms
    twilio_client = client
    sms = twilio_client.account.sms.messages.create(
        :body => 'test sms sending bny twillio',
        #:to => '+79242173029',
        :to => '4259545072',
        :from => Configurations[:twilio_from_number]
    )
    sms.body
  end

  def client
    unless @twilio_client
      @twilio_client = Twilio::REST::Client.new Configurations[:twilio_sid], Configurations[:twilio_token] #if Rails.env.production?
      #@twilio_client ||= Twilio::REST::Client.new Configurations[:test_twilio_sid], Configurations[:test_twilio_token]
      #@twilio_client = Twilio::REST::Client.new 'ACf890929de15716ba6d25e9a6f9a4671f', '9bfd238a96364f499c4ab34efac3d195'
      #@twilio_client = Twilio::REST::Client.new 'ACf66d7d9ca3da191581fa6b4c483ae95d', '084120513fe40ab109218b97798c8b67'
    end
    @twilio_client
  end

  protected
  def def_to
    self.to ||= user.phone
  end
end
