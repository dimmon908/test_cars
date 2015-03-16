#encoding: utf-8
module Classes
  class BusinessAccount < Classes::BaseBusinessAccount

    validates_presence_of     :business_name
    validates_presence_of     :company_address
    validates_presence_of     :city

    def self.users
      Classes::BusinessAccount::where('role_id in (?)', Role::business.all.collect {|r| r.id })
    end

    def email_confirm
      email = EmailsPull.create([
          :email_id => Email::select(:id).where(:internal_name => :personal_register_confirm).id,
          :user_id => self.id,
          :params => {
              :last_name => last_name,
              :first_name => first_name,
              :email => self.email,
              :password => password,
              :username => username,
              :link => '',
              :code => activate_data.code }
      ])[0]

      email.send_email
    end

    def send_net_terms
      EmailsPull::create({
           :email => Email::find_by_internal_name(:send_net_terms),
           :user_id => self.id,
           :params => {
               :last_name => self.last_name,
               :first_name => self.first_name,
               :email => self.email,
               :phone => self.phone,
               :company_name => self.business_name,
           },
           :to_email => Configurations[:admin_email]
       })
    end

    def send_registered
      EmailsPull::create({
           :email => Email::find_by_internal_name(:business_registered),
           :user_id => self.id,
           :params => {
               :last_name => self.last_name,
               :first_name => self.first_name,
               :email => self.email,
               :phone => self.phone,
               :company_name => self.business_name,
           }
       })
    end

    protected

    def create_role
      unless role_id
        role = Role.find_by_internal_name :business
        self.role = role
      end
    end

    def after_create_callback
      super
      self.send_net_terms if self.net_terms?
      self.send_registered
    end

  end
end
