#encoding: utf-8
module Classes
  class DriverAccount < User
    attr_accessor :driver
    def additional_info
      get_driver.additional_info
    end

    def get_driver
      unless driver
        self.driver = Driver.find_by_user_id id
      end
      driver
    end

    def basic_info
      get_driver.basic_info
    end

    protected
    def create_role
      unless self.role_id
        role = Role.find_by_internal_name :driver
        self.role = role
        #self.role_id = role.id
      end
    end

    def password_required?
      !self.id.nil?
    end
  end
end