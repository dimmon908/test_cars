#encoding: utf-8
# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  username               :string(255)
#  phone                  :string(255)
#  status                 :integer
#  can_receive_request    :boolean
#  old_data               :string(255)
#  card_id                :integer
#  role_id                :integer
#  business_info_id       :integer
#  approve                :boolean
#  partner_id             :integer
#  api_token              :string(50)
#  token_expire           :datetime
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  confirmation_token     :string(255)
#  unconfirmed_email      :string(50)
#

module Classes
  class PersonalAccount < Classes::ClientAccount
    include PersonalAccountExt::ExportCsv

    validates_presence_of :email

    validates :credit_card, :credit_presence => :need_validate?, :credit_card => :need_validate?, :credit_card_length => :need_validate?
    validates :cvv, :credit_presence => :need_validate?, :length => { :minimum => 3, :maximum => 4, :allow_blank => true  }, :credit_card_cvv => :need_validate?

    validates :expiration_date_month, :credit_card_online => :need_validate?, :credit_presence => :need_validate?
    validates :expiration_date_year, :credit_card_online => :need_validate?, :credit_presence => :need_validate?
    validates :postal_code, :credit_card_online => :need_validate?
    validates :credit_card, :credit_card_online => :need_validate?
    validates :cvv, :credit_card_online => :need_validate?


    def self.users
      where(:role_id => Role::personal.first.id)
    end

    def email_confirm
      email = EmailsPull.create(
        {
          :email  => Email::find_by_internal_name(:personal_register_confirm),
          :user   => self,
          :params => {
              :last_name => last_name,
              :first_name => first_name,
              :email => self.email,
              :password => password,
              :username => username,
              :link => '',
              :code => activate_data.code
          }
        }
      )

      email.send_email
    end

    protected
    def create_role
      self.role = Role.find_by_internal_name :personal unless self.role_id
    end

    def after_initialize_callback
      super
      self.need_validate = false
    end

    def after_create_callback
      super
      EmailsPull::create({
          :email => Email::find_by_internal_name(:personal_registered),
          :user_id => self.id,
          :params => {
              :last_name => self.last_name,
              :first_name => self.first_name,
              :email => self.email,
              :username => self.username,
              :phone => self.phone
          }
      })
    end

  end
end
