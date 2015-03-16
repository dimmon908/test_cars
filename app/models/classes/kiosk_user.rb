module Classes
  class KioskUser < Classes::PersonalAccount

    belongs_to :swipe_card

    protected
    def before_create_callback
      self.first_name = '' if first_name.nil?
      self.last_name = '' if last_name.nil?
      self.password = Configurations[:default_kiosk_user_password].to_s if password.nil?
      self.show = false
      super

    end

  end
end
