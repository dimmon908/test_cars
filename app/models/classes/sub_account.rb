#encoding: utf-8
module Classes
  class SubAccount < Classes::BaseBusinessAccount
    belongs_to :partner, :class_name => 'Classes::BusinessAccount'

    before_validation :before_validate

    attr_accessible :partner, :sub_credit_limit
    attr_accessor :sub_credit_limit

    def self.users(partner)
      where('role_id IN (?) and partner_id = ?', Role::users.all.collect { |r| r.id }, partner.partner_id)
    end

    def send_email
    end

    def self.get(partner)
      if partner.role? :admin
        where('`role_id` IN (?)', Role.users.all.collect { |r| r.id })
      else
        where('`role_id` IN (?) and `partner_id` = ?', Role.users.all.collect { |r| r.id }, partner.id)
      end
    end

    def send_registered
      EmailsPull::create({
           :email => Email::find_by_internal_name(:sub_account_registered),
           :user_id => id,
           :params => {
               :last_name => last_name,
               :first_name => first_name,
               :email => email,
               :phone => phone,
               :company_name => business_name,
               :login => username,
               :password => password
           }
       })
    end

    protected
    def after_create_callback
      super
      self.send_registered
    end

    def after_initialize_callback
      super
      if self.partner.nil? && !self.partner_id.nil?
        self.partner = Classes::BusinessAccount::find(self.partner_id)
      end
      self.partner
    end

    def before_validate
      self.password = self.last_name.downcase + self.first_name[0].downcase unless self.id || self.password
      self.zip_code = self.partner.zip_code unless self.zip_code
      self.credit_card = self.partner.credit_card unless self.credit_card
      self.cvv = self.partner.cvv  unless self.cvv
      self.expiration_date = self.partner.expiration_date unless self.expiration_date
      self.card = self.partner.card unless self.card
      self.card_id = self.partner.card.id if (self.card.blank? && self.partner.card.present?)
    end

    def create_role
      unless self.role_id
        role = Role.find_by_internal_name :sub_account
        self.role = role
      end
    end

    def load_profile
      super
      if self.profile && self.user_profile.first_name
        self.sub_credit_limit = self.user_profile.credit_limit
      end
    end

    def create_profile
      super
      if self.profile && self.first_name
        self.user_profile.credit_limit = self.sub_credit_limit
        self.user_profile.save
      end
    end

    def save_profile
      super
      if self.profile && self.first_name
        self.user_profile.credit_limit = self.sub_credit_limit
        self.user_profile.save
      end
    end

  end
end