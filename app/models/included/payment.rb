module Included
  module Payment
    def pre_payment
      payment_base = ::Payment::Base::by_type(payment, user, get_transaction)
      (payment_base.check_possibility) ?
          true :
          begin
            self.errors[:payment] << payment_base.message
            false
          rescue Exception => e
            Log.exception e
            false
          end
    end

    def apply_pay
      #Log << {:payment => payment, :user => user, :transaction => transaction}.to_s
      res = ::Payment::Base::by_type(payment, user, transaction).payment
      if res
        transaction.charged = transaction.full_price
        transaction.save
      end
      res
    end

    def void
      refund! if ::Payment::Base::by_type(payment, user, transaction).void
    end

    def credit_card?
      self.payment.to_sym == :CC
    end

    def passenger_credit_card?
      self.payment.to_sym == :passenger_credit_card
    end

    def net_terms?
      self.payment.to_sym == :Net_Terms
    end

    def need_auth_pay?
      self.payment.to_sym == :CC
    end
  end
end
