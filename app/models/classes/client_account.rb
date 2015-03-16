#encoding: utf-8
module Classes
  class ClientAccount < User
    attr_accessible :credit_card, :cvv, :postal_code, :expiration_date, :card, :photo,
                    :expiration_date_month, :expiration_date_year,
                    :owner_name, :credit_card_type

    attr_accessor :credit_card, :cvv, :expiration_date, :postal_code, :card,
                  :expiration_date_month, :expiration_date_year, :credit_card_type, :owner_name

    attr_accessor :need_validate

    def need_validate?
      need_validate
    end

    def show_card
      ".... .... .... #{credit_card.to_s[-4,4]}"  if card
    end

    def payment_info
      {
          :first_name => first_name,
          :last_name => last_name,
          :zip => postal_code,
          :country => country,
          :phone => phone,
          :email => email,
          :cust_id => id,
          :ship_to_first_name => first_name,
          :ship_to_last_name => last_name,
          :ship_to_zip => postal_code,
          :ship_to_country => country,
          :cust_type => :personal
      }
    end

    def basic_info
      data = super
      if card
        data[:card_number] = credit_card
        if card.card_expire
          data[:expiration_date] = card.card_expire.utc.strftime('%m/%Y')
          data[:expiration_date_month] = card.card_expire.utc.strftime('%m')
          data[:expiration_date_year] = card.card_expire.utc.strftime('%Y')
        end

      end

      data.merge({
         :photo => user_profile.photo.url(:medium),
         :photo_path => user_profile.photo.url(:medium),
         :is_photo => (user_profile.photo_file_name.nil? ? 0: 1),
         :age => age.to_s,
         :gender => gender.to_s,
         :comments => comments,
         :cvv => cvv,
         :postal_code => postal_code,
         :card_id => card_id
       })
    end

    def get_card
      if card.nil? && id
        if card_id && Card::where(:id => card_id).any?
          self.card = Card::find card_id
        # else
        #   self.card = Card.new
        #   self.card.card_number = credit_card
        #   self.card.card_expire = Date.parse "#{expiration_date_year}-#{expiration_date_month.to_s.rjust(2, '0')}-01"
        #   self.card.cvv = cvv
        end

        #unless self.card
        #  card = Card.new
        #  card.checked = 0
        #  card.save :validate => false
        #  self.card_id = card.id
        #  self.card = card
        #end
      end

      if card && card.user_id.blank?
        card.user_id = partner_id
        card.save :validate => false
      end

      card
    end

    def additional_info
      data = super
      data.merge!({:card_id => card_id, :active_request => false})
      if Request.active_user(id).any?
        request = Request.active_user(id).first
        data.merge!(
            {
                :active_request => true,
                :request_id => request.id,
                :request_status => request.status,
                :request => request.additional_info
            }
        )
      end
      data
    end

    protected

    def before_create_callback
      super
      create_card
    end

    def save_additional_info
      super
      save_card
    end

    def get_additional_info
      super
      load_card
    end

    private

    def create_card
      if card.nil? && !credit_card.blank?
        card = Card.new
        card.checked = 0

        card.card_number = credit_card
        card.card_expire = Date.parse "#{expiration_date_year}-#{expiration_date_month.to_s.rjust(2, '0')}-01"
        card.cvv = cvv
        card.postal_code = postal_code
        card.type_name = credit_card_type
        card.owner = owner_name

        if id
          card.user = self
          card.user_id = id
        else
          card.last_name = last_name
          card.first_name = first_name
        end


        unless card.save :validate => false
          errors[:credit_card] = card.errors[:card_number]
          errors[:cvv] = card.errors[:cvv]
        end

        self.card = card
        self.card_id = card.id
        #self.save
      end
    end

    def save_card
      self.card = Card.new unless get_card
      unless credit_card.blank?
        card.card_number = credit_card

        if expiration_date_year && expiration_date_month
          card.card_expire = Date.parse "#{expiration_date_year}-#{expiration_date_month.to_s.rjust(2, '0')}-01"
        end

        card.cvv = cvv
        card.postal_code = postal_code
        card.type_name = credit_card_type
        card.owner = owner_name
        card.user_id = partner_id

        unless card.save :validate => false

        end

      end
    end

    def load_card
      if get_card && card.card_number
        self.credit_card = card.card_number
        self.expiration_date_month = card.card_expire.utc.to_date.strftime('%m').to_i
        self.expiration_date_year = card.card_expire.utc.to_date.strftime('%y').to_i
        self.expiration_date =  card.card_expire.utc.to_date.strftime('%m/%y')
        self.postal_code = card.postal_code
        self.credit_card_type = card.type_name
        self.owner_name = card.owner
        self.cvv = card.cvv
      end
      true
    end
  end
end