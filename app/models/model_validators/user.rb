module ModelValidators
  module User
    protected
    def password_required?
      id.nil? || password.nil?
    end

    def first_name_reacquired?
      first_name.nil?
    end

    def last_name_reacquired?
      last_name.nil?
    end

    def phone_reacquired?
      phone.nil?
    end

    def email_reacquired?
      email.nil?
    end
  end
end
