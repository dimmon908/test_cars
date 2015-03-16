module Included
  module Profile
    def profile
      (self.user_profile = id ? UserProfile::find_or_create_by_user_id(id) : UserProfile.new) unless user_profile
      user_profile
    end
    protected
    def load_profile
      if profile && user_profile.first_name
        self.first_name   = user_profile.first_name
        self.last_name    = user_profile.last_name
        self.zip_code     = user_profile.zip_code
        self.phone_code   = user_profile.phone_code
        self.gender       = user_profile.gender
        self.age          = user_profile.age
        self.comments     = user_profile.comments
        self.params       = user_profile.params
        self.photo        = user_profile.photo
        self.birth_date   = user_profile.birth_date
        self.payment      = user_profile.payment
        self.country      = user_profile.country
        self.device_id    = user_profile.device_id
        self.device       = user_profile.device
        self.online       = user_profile.online
        self.last_access  = user_profile.last_access
      end
    end

    def create_profile
      save_profile
      by_session
    end

    def save_profile
      if profile && first_name
        user_profile.first_name  = first_name
        user_profile.last_name   = last_name
        user_profile.zip_code    = zip_code
        user_profile.photo       = photo
        user_profile.phone_code  = phone_code
        user_profile.gender      = gender
        user_profile.age         = age
        user_profile.comments    = comments
        user_profile.params      = params
        user_profile.birth_date  = birth_date
        user_profile.country     = country
        user_profile.payment     = payment
        user_profile.device_id   = device_id
        user_profile.device      = device
        user_profile.online      = online
        user_profile.last_access = last_access
        user_profile.save
      end

      if id && user_profile.user_id.blank?
        user_profile.user_id = id
        user_profile.save
      end
    end

  end
end
