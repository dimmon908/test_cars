module Trip
  module Check
    def check_recommend
      if recommend?
        params['passengers'] = [
            {
                :name      => recommended_first_name,
                :last_name => recommended_last_name,
                :phone     => recommended_phone,
                :room      => recommended_room,
                :reference => recommended_reference
            }
        ]
        self.phone           = recommended_phone
      else
        self.phone = user.phone if user
      end
    end

    def check_promo
      if promo
        self.promo_code = PromoCode::find_by_code self.promo if PromoCode::where(:code => self.promo).any?
        self.promo_code = PromoCode::find_by_name promo if PromoCode::where(:name => promo).any?
      end
    end

    def check_date_save
      begin
        if self.date.is_a?(String)
          data        = {:previous => self.date.to_s}
          self.date   = self.datetime_date
          data[:data] = self.date.to_s
        end

        self.to = MessagePack::pack(to.values).force_encoding(Encoding::BINARY) if !to.blank? && to.is_a?(Hash) rescue nil
        self.to = MessagePack::pack(to).force_encoding(Encoding::BINARY) if !to.blank? && to.is_a?(Array) rescue nil
      rescue Exception => e
        Log.exception e
      end
    end
  end
end