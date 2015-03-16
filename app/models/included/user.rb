module Included
  module User

    def full_name
      "#{first_name} #{last_name}"
    end

    def base_url
      role.internal_name.to_s
    end

    def get_photo
      return photo.to_s if ::File.exist? photo.to_s
      '/img/missing-avatar.png'
    end

    def enabled?
      status.nil? || status.to_i > 0
    end

    def additional_info
      {}
    end

    def basic_info
      {
          :first_name => first_name,
          :last_name => last_name,
          :phone => phone,
          :email => email,
          :id => id,
      }
    end

    def status_name
      return :Disabled unless status
      :Enabled
    end

    def activate_by_code!(code)
      activate! if activate_data && activate_data.code == code
    end

    def activate!
      self.status = 1
      save(:validate => false)
    end

    def login_path
      case true
        when ::Role::personal?(self)
          '/personal/login'
        when ::Role::admin?(self)
          '/admin/login'
        when ::Role::business?(self)
          '/admin/login'
        else
          '/'
      end
    end

  end
end
