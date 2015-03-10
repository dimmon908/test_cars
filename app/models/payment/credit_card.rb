module Payment
  class CreditCard < Payment::Base
    def check_possibility
      return true if transaction.full_price == 0
      bill = billing
      resp = bill.authorize
      if resp && resp.success?
        true
      else
        self.message = 'Check payment possibility failed'
        false
      end
    end

    def void
      bill = billing
      bill.void
    end

    def pre_payment
      if transaction.gratuity.to_f > 0
        void
        check_possibility
      end
    end

    protected
    def proceed
      bill = billing
      #bill.apply_payment
      bill.prior
    end

    private
    # @return [Payment::AuthorizeNet]
    def billing
      pay = Payment::AuthorizeNet.new
      pay.transaction = transaction
      pay.client = client
      pay.card = client.card
      pay
    end
  end
end