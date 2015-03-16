class Referrer < ActiveRecord::Base
  after_initialize :after_init
  before_save :before_save
  after_create :after_create

  belongs_to :user
  attr_accessible :email, :provider, :sended, :user


  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless self.class.exists?(token: random_token)
    end
  end

  private
  def after_init
    self.generate_token if self.id.to_i > 0 && self.token.blank?
  end

  def before_save
    self.generate_token if self.token.blank?
  end

  def after_create
    if Email::where(:internal_name => :get_a_free_ride).any?
      EmailsPull::create({
        :email => Email::find_by_internal_name(:get_a_free_ride),
        :user => self.user,
        :to_email => self.email,
        :params => {:first_name => self.user.first_name, :last_name => self.user.last_name, :token => self.token}
      })
    end

  end
end
