module Payment
  class NetTerms < Payment::Base
    def check_possibility
      if client.role_class.can_credit? transaction.full_price
        true
      else
        self.message = 'Check payment possibility failed'
        false
      end
    end

    def void
      client.void_credit transaction.full_price
    end

    protected
    def proceed
      client.proceed_credit transaction.full_price
    end
  end
end