#encoding: utf-8
module Notify
  module User
    def send_change_password_data
      SmsMessagesPull::create({
          :sms_message => SmsMessage.find_by_internal_name(:password_change),
          :user_id => id
      }) if SmsMessage.by_name(:password_change).any?
      EmailsPull::create({
           :email => Email.find_by_internal_name(:password_change),
           :user_id => id,
           :to_email => email
       }) if Email.by_name(:internal_name => :password_change).any?
    end

    def send_reset_password_instructions
      raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)

      self.reset_password_token   = enc
      self.reset_password_sent_at = Time.now.utc
      save(:validate => false)

      if find_element.to_s =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
        send_devise_notification(:reset_password_instructions, raw, {})
      else
        send_forgot_password_phone raw
      end

      raw
    end

    def send_forgot_password_phone(token)
      if SmsMessage.by_name(:forgot_password).any?
        sms = SmsMessagesPull.create({
          :sms_message  => SmsMessage::find_by_internal_name(:forgot_password),
          :user_id      => id,
          :params       => {:resource => self, :token => token, :host => configatron.host}
         })
        errors[:email_template] << 'Error while sending sms' unless sms.send_sms
      else
        errors[:email_template] << 'No email'
      end
    end

    def send_change_email
      if SmsMessage.by_name(:email_change).any?
        SmsMessagesPull::create({
            :sms_message => SmsMessage::find_by_internal_name(:email_change),
            :user_id => id,
        })
      end

      if Email::by_name(:email_change).any?
        EmailsPull::create({
             :email => Email::find_by_internal_name(:email_change),
             :user_id => id,
             :to_email => params['old_email']
         })
      end
    end

    def send_change_cc
      if SmsMessage::by_name(:cc_change).any?
        SmsMessagesPull::create({
            :sms_message => SmsMessage::find_by_internal_name(:cc_change),
            :user_id => id
        })
      end

      if Email::by_name(:cc_change).any?
        EmailsPull::create({
             :email => Email::find_by_internal_name(:cc_change),
             :user_id => id
         })
      end
    end

    def email_confirm
    end
  end
end