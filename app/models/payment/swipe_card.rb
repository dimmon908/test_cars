module Payment
  class SwipeCard < Payment::Base

    def check_possibility
      return true if transaction.full_price == 0
      bill = billing
      resp = bill.authorize
      if resp &&  resp.success?
        true
      else
        self.message = resp.response_reason_text
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
      bill.prior
    end

    private
    # @return [Payment::AuthorizeNetSwiper]
    def billing
      pay = Payment::AuthorizeNetSwiper.new
      pay.transaction = transaction
      pay.client = client
      pay.card = ::SwipeCard.find client.swipe_card_id
      pay
    end
  end
end