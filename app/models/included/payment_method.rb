module Included
  module PaymentMethod
    def card_payment?
      payment.to_sym == :CC
    end

    def net_terms?
      payment.to_sym == :Net_Terms
    end
  end
end
