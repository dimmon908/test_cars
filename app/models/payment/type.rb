module Payment
  class Type
    NET_TERMS   = :Net_Terms
    CREDIT_CARD = :CC
    CHARGE_CARD = :passenger_credit_card
    KIOSK_SWIPER = :kiosk_swiper

    def self.card_payment? element
      element.payment.to_sym == CREDIT_CARD rescue nil
    end

    def self.net_terms? element
      element.payment.to_sym == NET_TERMS rescue nil
    end

    def self.passenger_credit_card? element
      element.payment.to_sym == CHARGE_CARD rescue nil
    end
  end
end