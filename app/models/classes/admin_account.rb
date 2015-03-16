#encoding: utf-8
module Classes
  class AdminAccount < User

    attr_accessor :need_notify
    attr_accessible :need_notify

    def self.users
      User::where(:role_id => Role::admins.select(:id).first.id)
    end

    def can_credit?(amount)
      true
    end

    def need_notify?
      need_notify.to_i > 0
    end

    protected
    def create_role
      unless self.role_id
        role = Role.find_by_internal_name :admin
        self.role = role
      end
    end

    def after_initialize_callback
      super
      self.need_notify = params['need_notify'].nil? ? 1 : params['need_notify']
    end

    def before_save_callback
      super
      params['need_notify'] = need_notify
      true
    end

    def before_create_callback
      super
      self.status ||= 1
    end

    def after_create_callback
      super
      puts "Admin #{email} was created"
    end

    def default_payment
      :Net_Terms
    end
  end
end
