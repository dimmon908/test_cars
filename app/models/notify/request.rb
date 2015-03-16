#encoding: utf-8
module Notify
  module Request
    def declined_sms
      #return nil unless SmsMessage::by_name(:declined_trip).any?
      #
      #sms = SmsMessage::find_by_internal_name(:declined_trip)
      #params = {}
      #send_sms({ :sms_message => sms, :status => :new, :user => user, :params => params })
    end

    def cancelled_sms
      return nil unless SmsMessage::by_name(:cancelled_trip).any?

      sms = SmsMessage::find_by_internal_name(:cancelled_trip)
      params = {}
      send_sms({ :sms_message => sms, :status => :new, :user => user, :params => params })
    end

    def started_trip_sms
      return nil unless SmsMessage::by_name(:trip_started).any?

      sms = SmsMessage::find_by_internal_name(:trip_started)
      params = {}
      send_sms({ :sms_message => sms, :status => :new, :user => user, :params => params })
    end

    def finished_trip_sms
      return nil unless SmsMessage::by_name(:finished_trip).any?

      sms = SmsMessage::find_by_internal_name(:finished_trip)
      params = {
          :final_fare => number_to_currency(charged_price),
      }
      send_sms({ :sms_message => sms, :status => :new, :user => user, :params => params })
    end

    def additional_info_text
      res = ''
      if recommend?
        res += "\n
\t - Booked for: #{recommended_first_name} #{recommended_last_name}\n
\t________________________________________________"
      end
      res
    end

    def notify_param
      distance = real_distance rescue 0
      distance ||= 0
      resp = {
          :number => id,
          :phone => user.phone,
          :from => from,
          :to => to.last,
          :user_first_name => user.first_name,
          :user_last_name => user.last_name,
          :name => "#{user.first_name} #{user.last_name}",
          :request_date => date,
          :base_fare => vehicle.rate,
          :distance => distance,
          :time => real_time,
          :final_rate => charged_price,
          :base_rate => number_to_currency(transaction.base.to_f - transaction.promo.to_f),
          :gratuity => number_to_currency(transaction.gratuity),
          :total_rate => number_to_currency(transaction.total),
          :comments => comment,
          :additional_info => additional_info_text,
          :request_id => id
      }
      resp.merge!({
                      :last_name => driver.last_name,
                      :first_name => driver.first_name,
                      :driver_name => driver.full_name,
                      :driver_phone => self.driver.phone,
                      :car_colour => driver.car.color,
                      :car_model => driver.car.model_name
                  }) if driver
      resp
    end

    #-------accepted
    def accepted_sms
      return nil unless SmsMessage::by_name(:order_accepted).any?

      sms = SmsMessage::find_by_internal_name(:order_accepted)
      sms_3rd = SmsMessage::find_by_internal_name(:order_accepted_3rd)

      params = notify_param
      send_sms({ :sms_message => sms, :status => :new, :user => user, :params => params }, sms_3rd)

      if recommend?
        sms = SmsMessage::find_by_internal_name(:order_accepted_friend)
        sms_3rd = SmsMessage::find_by_internal_name(:order_accepted_friend_erd)

        send_sms({ :sms_message => sms, :status => :new, :user => user, :params => params }, sms_3rd)
      end

    end
    def accepted_email
      return nil unless Email::by_name(:order_accepted).any?

      email = Email::find_by_internal_name(:order_accepted)
      email_3rd = Email::find_by_internal_name(:order_accepted_3rd)

      params = notify_param
      send_email({ :email => email, :user => user, :params => params }, email_3rd)

      if recommend?
        email = Email::find_by_internal_name(:order_accepted_friend)
        email_3rd = Email::find_by_internal_name(:order_accepted_friend_3rd)
        send_email({ :email => email, :user => user, :params => params }, email_3rd)
      end
    end

    #-------picked up
    def picked_up_sms
      sms_3rd = SmsMessage::find_by_internal_name(:order_picked_up_3rd)
      params = notify_param
      send_sms({ :status => :new, :user => user, :params => params }, sms_3rd)

      if recommend?
        sms = SmsMessage::find_by_internal_name(:order_picked_up_friend)
        sms_3rd = SmsMessage::find_by_internal_name(:order_picked_up_friend_3rd)

        send_sms({ :sms_message => sms, :status => :new, :user => user, :params => params }, sms_3rd)
      end
    end
    def picked_up_email
      return nil unless Email::where(:internal_name => :order_picked_up_friend).any?

      email_3rd = Email::find_by_internal_name(:order_picked_up_3rd)
      params = notify_param
      send_email({ :status => :new, :user => user, :params => params }, email_3rd)

      if recommend?
        email = Email::find_by_internal_name(:order_picked_up_friend)
        email_3rd = Email::find_by_internal_name(:order_picked_up_friend_3rd)

        send_email({ :email => email, :status => :new, :user => user, :params => params }, email_3rd)
      end
    end

    #-------arrived
    def arrived_sms
      return nil unless SmsMessage::by_name(:order_arrived).any?

      sms = SmsMessage::find_by_internal_name(:order_arrived)
      sms_3rd = SmsMessage::find_by_internal_name(:order_arrived_3rd)
      params = notify_param
      send_sms({ :sms_message => sms, :status => :new, :user => user, :params => params }, sms_3rd)

      if recommend?
        sms = SmsMessage::find_by_internal_name(:order_arrived_friend)
        sms_3rd = SmsMessage::find_by_internal_name(:order_arrived_friend_3rd)
        send_sms({ :sms_message => sms, :status => :new, :user => user, :params => params }, sms_3rd)
      end
    end
    def arrived_email
      return nil unless Email::by_name(:order_arrived).any?

      email = Email::find_by_internal_name(:order_arrived)
      email_3rd = Email::find_by_internal_name(:order_arrived_3rd)
      params = notify_param
      send_email({ :email => email, :user => user, :params => params }, email_3rd)

      if recommend?
        email = Email::find_by_internal_name(:order_arrived_friend)
        email_3rd = Email::find_by_internal_name(:order_arrived_friend_3rd)
        send_email({ :email => email, :user => user, :params => params }, email_3rd)
      end
    end

    #-------finished
    def finished_sms
      return nil unless SmsMessage::by_name(:order_finished).any?

      sms = SmsMessage::find_by_internal_name(:order_finished)

      sms_3rd = SmsMessage::find_by_internal_name(:order_finished_3rd)
      params = notify_param
      send_sms({ :sms_message => sms, :status => :new, :user => user, :params => params }, sms_3rd)

      if recommend?
        sms = SmsMessage::find_by_internal_name(:order_finished_friend)
        sms_3rd = SmsMessage::find_by_internal_name(:order_finished_friend_3rd)
        send_sms({ :sms_message => sms, :status => :new, :user => user, :params => params }, sms_3rd)
      end
    end

    def finished_email
      return nil unless Email::by_name(:order_finished).any?

      email = Email::find_by_internal_name :order_finished
      email_3rd = Email::find_by_internal_name(:order_finished_3rd)
      params = notify_param
      send_email({ :email => email, :status => :new, :user => user, :params => params }, email_3rd)

      if recommend?
        email = Email::find_by_internal_name(:order_finished_friend)
        email_3rd = Email::find_by_internal_name(:order_finished_friend_3rd)

        send_email({ :email => email, :status => :new, :user => user, :params => params }, email_3rd)
      end
    end

    #-------decline
    def decline_sms
      #return nil unless SmsMessage::by_name(:order_declined).any?
      #
      #sms = SmsMessage::find_by_internal_name(:order_declined)
      #params = notify_param
      #
      #send_sms({ :sms_message => sms, :status => :new, :user => user, :params => params })
      #
      #if recommend?
      #  sms = SmsMessage::find_by_internal_name(:order_declined_friend)
      #  send_sms({ :sms_message => sms, :status => :new, :user => user, :params => params })
      #end
    end
    def decline_email
      #return
      #return nil unless Email::by_name(:order_declined).any?
      #
      #email = Email::find_by_internal_name(:order_accepted)
      #params = notify_param
      #send_email({ :email => email, :user => user, :params => params })
      #
      #if recommend?
      #  email = Email::find_by_internal_name(:order_declined_friend)
      #  send_email({ :email => email, :user => user, :params => params })
      #end
    end

    #-------created
    def created_sms
      return nil unless SmsMessage::by_name(:order_created).any?

      sms = ::SmsMessage.find_by_internal_name(:order_created)
      send_sms({:status => :new, :user => user, :params => notify_param }, sms)
    end
    def created_email
      return nil unless Email::by_name(:order_created).any?

      email = recommend? ? ::Email.find_by_internal_name(:order_created) : nil
      email_3rd = ::Email.find_by_internal_name(:order_created)
      send_email({ :email => email, :status => :new, :user => user, :params => notify_param }, email_3rd)
    end

    #-------cancel
    def cancel_sms
      return nil unless ::SmsMessage.by_name(:order_canceled).any?

      sms = ::DriverRequestHistory.accepts(id).any? ? ::SmsMessage.find_by_internal_name(:order_canceled) : nil
      sms_3rd = ::SmsMessage.find_by_internal_name :order_canceled_3rd
      params = notify_param
      send_sms({:sms_message => sms, :status => :new, :user => user, :params => params }, sms_3rd)

      if recommend?
        sms = ::SmsMessage.find_by_internal_name(:order_canceled_friend)
        sms_3rd = ::SmsMessage.find_by_internal_name :order_canceled_friend_3rd
        send_sms({:sms_message => sms, :status => :new, :user => user, :params => params }, sms_3rd)
      end
    end
    def cancel_email
      return nil unless Email.by_name(:order_canceled).any?

      email = ::DriverRequestHistory.accepts(id).any? ? ::Email.find_by_internal_name(:order_canceled) : nil
      email_3rd = ::Email.find_by_internal_name(:order_canceled_3rd)
      params = notify_param
      send_email({ :email => email, :status => :new, :user => user, :params => params }, email_3rd)
      if recommend?
        email = ::Email.find_by_internal_name(:order_canceled_friend)
        email_3rd = ::Email.find_by_internal_name(:order_canceled_friend_3rd)

        send_email({ :email => email, :status => :new, :user => user, :params => params }, email_3rd)
      end

    end

    def gratuity_sms
      return nil unless ::SmsMessage.by_name(:gratuity).any? && transaction

      sms = ::SmsMessage.find_by_internal_name(:gratuity)
      params = {:gratuity => ::ActionController::Base.helpers.number_to_currency(transaction.spec_gratuity.to_f) }
      send_sms({ :sms_message => sms, :status => :new, :user => user, :params => params })
      true
    end

    def future_request_not_responded_to_sms
      return nil unless ::SmsMessage::where(:internal_name => :future_request_not_responded_to).any?

      sms = ::SmsMessage::find_by_internal_name(:future_request_not_responded_to)
      params = notify_param.merge(:response_time_window => 25)

      #TODO: this is for demo purposes only, change to make ie permanent
      self.send_sms({ :sms_message => sms, :status => :new, :user => self.user, :params => params, :to => "+17077877707" })
      true
    end

    def notify_admin
      return if params['notify_admin']
      return if date > (Time.now + Configurations[:future_request_admin_call_time].minute)

      params['notify_admin'] = 1
      save :validate => false

      sms = ::SmsMessage::find_by_internal_name(:notify_admin_future)
      Classes::AdminAccount.where(:role_id => ::Role.admin.id).all.each do |admin|
        begin
          Log << {:admin => admin.id, :admin_name => admin.full_name, :need_notify => admin.need_notify, :is_need  => admin.need_notify?}.to_s
          next unless admin.need_notify?
          params = notify_param
          ::SmsMessagesPull::create({
                                      :sms_message => sms,
                                      :status => :new,
                                      :user => admin,
                                      :params => params,
                                  })
        rescue Exception => e
          ::Log.exception e
        end
      end
  end

    #general
    def send_sms(data, another = nil)
      if data[:sms_message]
        to = recommended_phone if recommended_phone
        to ||= user.phone
        data[:to] = to

        ::SmsMessagesPull.create(data)
      end

      if another
        data[:sms_message] = another

        notifications = params['notify']
        notifications ||= {}

        notifications.each_value do |value|
          data[:to] = value['value']
          ::SmsMessagesPull.create(data) if value['type'].to_s == 'phone'
        end
      end

    end
    def send_email(data, another = nil)
      if data[:email]
        data[:to_email] = user.email
        ::EmailsPull::create(data)
      end

      if another
        data[:email] = another
        notifications = params['notify']
        notifications ||= {}

        notifications.each_value do |value|
          data[:to_email] = value['value']
          ::EmailsPull::create(data) if value['type'].to_s == 'sms' && !value['value'].blank?
        end
      end
    end

    def notify_driver(driver_status = ::Chauffeur::Status::ACTIVE, status = ::Trip::Status::CANCELED, comment = 'cancel request')
      if driver && driver.device_id
        device = ::Device.device driver.device_id
        ::Device.send_notification(
            device,
            {:data => {:request_id => id, :request_type => :manually, :status => status}},
            "#{comment} [#{id}]"
        )
        driver.status = driver_status
        driver.save
      end
    end

    def notify_client(status = :cancelled, comment = 'cancel request')
      if user && user.user_profile.device_id
        profile = user.user_profile
        device = ::Device.device profile.device_id, profile.device
        return unless device
        ::Device.send_notification(
            device,
            {:data => {:request_id => id, :request_type => :manually, :status => status}},
            "#{comment} [#{id}]"
        )
      end
    end

    def broadcast
      data = {:data => {:request_id => id, :request_type => :broadcast}}
      add_notifications data
    end

    def broadcast_step
      params['broadcast_step'] || 1
    end

    def broadcast_step!
      broadcast_step = self.broadcast_step
      params['broadcast_step'] = broadcast_step + 1
      save
      broadcast_step
    end

    def broadcast_distance_by_step(step)
      case step
        when 1
          500
        when 2
          2000
        else
          nil
      end
    end

    def add_notifications(data)
      begin
        data = {:data => {:request_id => id, :request_type => :broadcast}}

        broadcast_step = broadcast_step!
        max_distance = broadcast_distance_by_step broadcast_step

        _dev = Device.new data, "new request [#{id}]"

        ::Driver.available.all.each do |driver|
          next if ::DriverRequestHistory.where(:request_id => id, :driver_id => driver.id, :status => :decline).any?

          device = ::Device.device driver.device_id
          next unless device

          begin
            if vehicle_id == driver.car.vehicle_id
              calc_distance = ::Location.distance_between_coordinates(from_coord, driver.get_coordinates)
              if  max_distance.blank? || calc_distance < max_distance
                log_data = {:type => :broadcast, :id => id,:name => driver.full_name,:max_distance => max_distance,:distance => calc_distance,:step => broadcast_step, :reg_id => device.registration_id}

                Rails.logger.fatal "broadcast = #{log_data}"
                #::Device.send_notification device, data, "new request [#{id}]"
                _dev.add_device device
              else
                log_data = {:type => 'broadcast fail',:id => id,:name => driver.full_name,:max_distance => max_distance,:distance => calc_distance,:step => broadcast_step, :reg_id => device.registration_id}
                Rails.logger.fatal "broadcast = #{log_data}"
              end
            else
              log_data = {:type => 'broadcast fail',:id => id,:name => driver.full_name,:v_id => vehicle_id,:car_v_id => driver.car.vehicle_id, :reg_id => device.registration_id}
              Rails.logger.fatal "broadcast = #{log_data}"
            end

          rescue Exception => e
            ::Log.exception e
            Rails.logger.fatal "broadcast exception = #{e.message}"
          end
        end

        _dev.release
      rescue Exception => e
        ::Log.exception e
      end
    end

    def add_notification(device, data, comment = 'new request')
      data[:device_id] = device.id

      notification = Gcm::Notification.new
      notification.device = device
      notification.collapse_key = "#{id}__#{comment}"
      notification.delay_while_idle = false
      notification.data = {:registration_ids => [device.registration_id], :data => data}
      notification.save

      data[:message_id] = notification.id

      notification.data = {:registration_ids => [device.registration_id], :data => data}
      notification.save
    end

  end
end
