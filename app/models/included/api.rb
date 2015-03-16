module Included
  module Api
    def api_login(system, device_id)
      generate_api_token

      user = ::User.user_object_by_role role, id

      user.device_id = device_id
      user.device = system
      user.last_access = Time.now
      user.online = 1

      Device.create_device device_id, system

      if user.is_a? ::Driver
        devices = ::Driver::where('online = 1 AND device_id = ? AND id != ?', device_id, id).all

        user.status = ::Chauffeur::Status::ACTIVE unless Chauffeur::Status.booked? user
        user.save :validate => false

        user = user.user

        user.device_id = device_id
        user.device = system
        user.last_access = Time.now
        user.online = 1
        user.save :validate => false

        is_driver = :yes
      else
        user.save :validate => false
        devices = ::UserProfile::where('online = 1 AND device_id = ? AND user_id != ?', device_id, id).all
        is_driver = :no
      end

      devices.each do |item|
        item.api_logout
      end

      {
          :user_id => user.id,
          :token => user.api_token,
          :token_expire => user.token_expire,
          :basic_info => user.basic_info,
          :additional_info => user.additional_info,
          :is_driver => is_driver
      }
    end

    def api_logout
      self.online = 0
      #self.api_token = nil
      #self.token_expire = nil
      #self.device_id = nil
      #self.device = nil
      save :validate => false

      if ::Role.driver? self
        driver = ::Driver.find_by_user_id id
        driver.car = nil
        driver.online = 0
        driver.status = :offline
        driver.save :validate => false
      end

    end

  end
end