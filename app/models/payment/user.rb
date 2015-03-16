module Payment
  module User
    def can_credit?(amount)
      false
    end
    def void_credit(amount)
      false
    end
    def proceed_credit(amount)
      false
    end

    protected
    def default_payment
      Payment::Type::CREDIT_CARD
    end
  end
end
