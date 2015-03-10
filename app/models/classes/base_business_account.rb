#encoding: utf-8
module Classes
  class BaseBusinessAccount < Classes::ClientAccount

    belongs_to :business_info
    belongs_to :terms_application

    attr_accessible :business_name, :business_type,
                    :years_in_business, :duns_no,
                    :company_address, :suite, :city, :business_zip_code,
                    :business_email, :business_phone,
                    :requests_number, :emplyees_number,
                    :approve, :credit_limit, :credit, :terms, :need_approve,
                    :term_applicant_first_name,:term_applicant_last_name, :term_applicant_phone_code,
                    :term_applicant_phone, :term_applicant_job_title, :term_applicant_email

    attr_accessor :business_name, :business_type,
                  :years_in_business, :duns_no,
                  :company_address, :suite, :city, :business_zip_code,
                  :business_email, :business_phone,
                  :requests_number, :emplyees_number,
                  :reward, :credit_limit, :credit, :terms, :need_approve,
                  :term_applicant_first_name,:term_applicant_last_name,
                  :term_applicant_phone_code, :term_applicant_phone,
                  :term_applicant_job_title, :term_applicant_email

    validates :credit_card, :credit_card => true, :credit_card_length => true, :credit_card_online => :need_validate?
    validates :cvv, :length => { :minimum => 3, :maximum => 4, :allow_blank => true }, :credit_card_cvv => true, :credit_card_online => :need_validate?

    validates :expiration_date_month, :credit_card_online => :need_validate?, :credit_card_business => true
    validates :expiration_date_year, :credit_card_online => :need_validate?, :credit_card_business => true

    def validate_card?
      validate_card
    end

    def validate_card
      @validate_card
    end

    def validate_card=(value)
      @validate_card = value
    end

    def payment_info
      super.merge({
                      :company => business_name,
                      :address => company_address,
                      :city => city,
                      :ship_to_company => business_name,
                      :ship_to_address => company_address,
                      :ship_to_city => city,
                      :cust_type => :business
                  })
    end

    def can_credit?(amount)
      Rails.logger.fatal({
            :business_credit_limit => business_info.credit_limit,
            :can_receive_request? => can_receive_request?,
            :credit_limit => credit_limit.to_f,
            :credit => credit.to_f,
            :amount => amount.to_f,
            :result => (credit_limit.to_f - credit.to_f) > amount.to_f
          }.to_s)
      return true if business_info.credit_limit.to_i == 0 || can_receive_request?
      (credit_limit.to_f - credit.to_f) > amount.to_f
    end

    def proceed_credit(amount)
      business_info.credit = business_info.credit.to_f + amount.to_f
      business_info.save :validate => false

      user_profile.credit = user_profile.credit + amount.to_f
      user_profile.save :validate => false
    end

    def void_credit(amount)
      business_info.credit = business_info.credit.to_f - amount.to_f
      business_info.save :validate => false

      user_profile.credit = user_profile.credit - amount.to_f
      user_profile.save :validate => false
    end

    def basic_info
      data = super
      data.merge({
                     :payment => self.payment,
                     :business_name => self.business_name,
                     :business_type => self.business_type,
                     :years_in_business => self.years_in_business,
                     :duns_no => self.duns_no,
                     :company_address => self.company_address,
                     :suite => self.suite,
                     :city => self.city,
                     :business_zip_code => self.business_zip_code,
                     :business_email => self.business_email,
                     :business_phone => self.business_phone,
                     :requests_number => self.requests_number,
                     :emplyees_number => self.emplyees_number,
                     :credit_limit => self.credit_limit,
                     :credit => self.credit,
                     :terms => self.terms
                 })
      data[:term_applicant_first_name] = self.terms_application.first_name if self.terms_application
      data[:term_applicant_last_name] = self.terms_application.last_name if self.terms_application
      data[:term_applicant_phone] = self.terms_application.phone if self.terms_application
      data
    end

    protected

    def default_payment
      :Net_Terms
    end

    def before_save_callback
      self.payment = :Net_Terms unless self.need_approve.blank?
      self.payment = :CC unless self.credit_card.blank?

      super
      save_business_info
    end

    def before_create_callback
      super
    end

    def after_save_callback
      if self.approved? && TermsApplication::where('user_id = ? and approved is null', self.id).any?
        term = TermsApplication::find_by_user_id self.id
        term.approved = Time.now
        term.save

        self.payment = :Net_Terms
      end
      super
    end

    def after_initialize_callback
      super
      load_business_info

      self.city ||= 'San Francisco'

      self.credit_limit ||= 0
      self.credit ||= 0
    end

    def after_create_callback
      super

      unless self.need_approve.blank?
        TermsApplication::create({
          :user_id => self.id,
          :received => Time.now,
          :first_name => self.term_applicant_first_name,
          :last_name => self.term_applicant_last_name,
          :email => self.term_applicant_email,
          :phone_code => self.term_applicant_phone_code,
          :phone => self.term_applicant_phone,
          :job_title => self.term_applicant_job_title
        })

        EmailsPull::create({
            :email => Email::find_by_internal_name(:send_net_terms),
            :user_id => self.id,
            :to_email => Configurations[:admin_email],
            :params => {
                :first_name => self.first_name,
                :last_name => self.last_name,
                :company_name => self.business_name,
                :phone => self.phone,
                :email => self.email
            }
        })

      end
    end

    def get_business_info
      unless self.business_info
        if self.business_info_id
          self.business_info = BusinessInfo::find self.business_info_id
        else
          self.business_info = BusinessInfo.new
          self.business_info.save
          self.business_info_id = self.business_info.id
        end
      end
      self.business_info
    end

    def load_business_info
      if self.get_business_info && self.business_info.name
        self.business_name = self.business_info.name
        self.business_type = self.business_info.type_name
        self.years_in_business = self.business_info.year_in_business
        self.duns_no = self.business_info.duns_number
        self.company_address = self.business_info.company_address
        self.suite = self.business_info.suite
        self.city = self.business_info.city
        self.business_zip_code = self.business_info.zip_code
        self.business_email = self.business_info.email
        self.business_phone = self.business_info.phone
        self.requests_number = self.business_info.requests_per_month
        self.emplyees_number = self.business_info.employees
        self.credit = self.business_info.credit
        self.credit_limit = self.business_info.credit_limit
        self.terms = self.business_info.terms
      end
    end

    def save_business_info
      if get_business_info
        self.business_info.name = self.business_name
        self.business_info.type_name = self.business_type
        self.business_info.year_in_business = self.years_in_business
        self.business_info.duns_number = self.duns_no
        self.business_info.company_address = self.company_address
        self.business_info.suite = self.suite
        self.business_info.city = self.city
        self.business_info.zip_code = self.business_zip_code
        self.business_info.email = self.business_email
        self.business_info.phone = self.business_phone
        self.business_info.requests_per_month = self.requests_number
        self.business_info.employees = self.emplyees_number
        self.business_info.credit = self.credit
        self.business_info.credit_limit = self.credit_limit
        self.business_info.terms = self.terms
        self.business_info.save
      end
    end
  end
end
