module Omnioauth
  module User
    def generate_api_token
      self.api_token = loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless self.class.exists?(api_token: random_token)
      end
      self.token_expire = Time.now + Configurations[:default_expire_token_date]
      self.password = '' unless password
      save :validate => false
    end

    #@return [ActivateData]
    def activate_data
      @activate_data = ActivateData.for_user(id).first unless @activate_data
      @activate_data
    end

    def generate_activation_data
      ActivateData.for_user(id).destroy_all if ActivateData.for_user(id).any?
      @activate_data = ActivateData::create({:user_id => id})
    end

    def self.from_facebook info
      User.find_by_email info.email
    end

    def self.from_facebook_email(email)
      User.find_by_email email
    end

    def apply_omniauth(omni)
      auth = Authentications.all :conditions => ['user_id = ? and provider = ?', id, omni.provider]
      if auth.empty?
        auth = Authentications.new
        auth.user_id = id
        auth.provider = omni.provider
        auth.uid = omni.uid
        auth.token = omni.credentials.token
        auth.token_secret = omni.credentials.secret
        auth.save
      end
    end

    def apply_mobileauth(data, provider)
      auth = Authentications.all :conditions => ['user_id = ? and provider = ?', self.id, provider]
      if auth.empty?
        auth = Authentications.new
        auth.user_id = id
        auth.provider = provider
        auth.uid = data[:uid]
        auth.token = data[:token]
        # question: is secret necessary? and if it is, then how do we grab it off fb ios api?
        auth.save
      end
      id
    end

    protected
    def by_session
      return nil unless id && uid

      credentials = Struct.new(:token, :secret)
      omni = Struct.new(:provider, :uid, :credentials)
      data = omni.new(provider, uid, credentials.new(token, token_secret))
      apply_omniauth data
    end
  end
end
