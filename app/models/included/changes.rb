module Included
  module Changes
    def send_change_password_data
      if SmsMessage::where(:internal_name => :password_change).any?
        sms =SmsMessage::find_by_internal_name :password_change
        SmsMessagesPull::create({
                                    :sms_message => sms,
                                    :user_id => self.id,
                                    :to => self.phone
                                })
      end

      if Email::where(:internal_name => :password_change).any?
        email =Email::find_by_internal_name :password_change
        EmailsPull::create({
                               :email => email,
                               :user_id => self.id,
                               :to_email => self.email
                           })
      end
    end

    def send_reset_password_instructions
      raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)

      self.reset_password_token   = enc
      self.reset_password_sent_at = Time.now.utc
      self.save(:validate => false)

      if self.find_element.to_s =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
        send_devise_notification(:reset_password_instructions, raw, {})
      else
        self.send_forgot_password_phone raw
      end

      raw
    end

    def send_forgot_password_phone token
      if SmsMessage::where(:internal_name => :forgot_password).any?
        sms = SmsMessagesPull.new
        sms.sms_message = SmsMessage::find_by_internal_name :forgot_password
        sms.user_id = self.id
        sms.to = self.phone
        sms.params = {:resource => self, :token => token, :host => configatron.host}
        unless sms.send_message
          self.errors[:email_template] << 'Error while sending sms'
        end
      else
        self.errors[:email_template] << 'No email'
      end
    end

    def send_change_email
      if SmsMessage::where(:internal_name => :email_change).any?
        sms =SmsMessage::find_by_internal_name :email_change
        SmsMessagesPull::create({
                                    :sms_message => sms,
                                    :user_id => self.id,
                                    :to => self.phone
                                })
      end

      if Email::where(:internal_name => :email_change).any?
        email =Email::find_by_internal_name :email_change
        EmailsPull::create({
                               :email => email,
                               :user_id => self.id,
                               :to_email => self.params['old_email']
                           })
      end
    end

    def send_change_cc
      if SmsMessage::where(:internal_name => :cc_change).any?
        sms =SmsMessage::find_by_internal_name :cc_change
        SmsMessagesPull::create({
                                    :sms_message => sms,
                                    :user_id => id
                                })
      end

      if Email::where(:internal_name => :cc_change).any?
        email =Email::find_by_internal_name :cc_change
        EmailsPull::create({
                               :email => email,
                               :user_id => id
                           })
      end
    end
  end
end