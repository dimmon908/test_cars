class Device

  def initialize(data = {}, comment = '')
    @data = data
    @comment = comment
    @registration_ids = []
  end

  def add_device(device)
    @registration_ids << device.registration_id
  end

  def message=(data)
    @data = data
  end

  def release
    return if @registration_ids.empty?
    gcm = GCM.new(configatron.gcm_on_rails.api_key)
    options = {
        :data => {:message => @data},
        :collapse_key => @comment
    }
    response = gcm.send_notification(@registration_ids, options)
    log_data = {
      :type => :gcm,
      :comment => @comment,
      :data => @data,
      :registration_ids => @registration_ids,
      :response => response
    }
    Rails.logger.fatal "now=#{Time.now} broadcast release = #{log_data}"
    response
  end

  def self.create_device(id, system)
    case system.to_s.downcase
      when 'android'
        Gcm::Device.create({:registration_id => id}) unless Gcm::Device::where(:registration_id => id).any?
      when 'ios'
        unless APN::Device::where(:token => id).any?
          dev = APN::Device.new
          dev.token = id
          dev.save
        end
      else
        nil
    end
  end

  def self.device(id, system = 'android')
    system ||= 'android'

    if system.to_s.downcase == 'android'
      condition = Gcm::Device::where(:registration_id => id)
    elsif system.to_s.downcase == 'ios'
      condition = APN::Device::where(:token => id)
    else
      condition = nil
    end
    condition.first if condition && condition.any?
  end

  def self.send_notification(device, data, comment = '')
    if device.is_a?Gcm::Device
      send_android device, data, comment
    elsif device.is_a?APN::Device
      send_ios device, data, comment
    else
      Log << ({:device => device.id, device_class: device.class, :data => data.to_s, comment: comment}).to_s
    end

  end

  # @param [Gcm::Device] device
  def self.send_android(device, data, comment = '')
    data[:device_id] = device.id

    notification = Gcm::Notification.new
    notification.device = device
    notification.collapse_key = comment
    notification.delay_while_idle = false
    notification.data = {:registration_ids => [device.registration_id], :data => data}
    notification.save

    data[:message_id] = notification.id

    notification.data = {:registration_ids => [device.registration_id], :data => data}
    notification.save
  end

  # @param [APN::Device] device
  def self.send_ios(device, data, comment = '')
    notification = APN::Notification.new
    notification.device = device
    notification.badge = 5
    notification.sound = true
    notification.alert = comment
    notification.custom_properties = data
    notification.save
    Log << ({:device => device.id, device_class: device.class, :data => data.to_s, comment: comment}).to_s
  end

end
