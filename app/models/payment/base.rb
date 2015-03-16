module Payment
  class Base

    attr_writer :transaction, :user
    attr_accessor :message

    # @return [Payment::Base]
    def self.by_type(payment, user, transaction)
      case payment.to_sym
        when Payment::Type::CREDIT_CARD
          Payment::CreditCard.new user, transaction
        when Payment::Type::NET_TERMS
          Payment::NetTerms.new user, transaction
        when Payment::Type::CHARGE_CARD
          Payment::ChargeCard.new user, transaction
        when Payment::Type::KIOSK_SWIPER
          Payment::SwipeCard.new user, transaction
        else
          Payment::CreditCard.new user, transaction
      end
    end

    def check_possibility
      true
    end

    def void
      true
    end

    def charge
      true
    end

    def initialize(user = nil, transaction = nil)
      @transaction = transaction
      @client        = user
    end

    # @return [Transaction]
    def transaction
      @transaction
    end

    # @return [Classes::ClientAccount]
    def client
      @client
    end

    def payment
      pre_payment
      proceed ? success_payment : fail_payment
      #post_payment
    end

    protected
    def post_payment
      true
    end

    def success_payment
      true
    end

    def fail_payment
      false
    end

    def proceed
      false
    end

    def pre_payment
      nil
    end
  end
end