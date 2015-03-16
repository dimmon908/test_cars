module AuthorizeNet
  class KeyValueTransaction < AuthorizeNet::Transaction

    def authorize(amount, credit_card, options = {})
      handle_payment_argument(credit_card)
      options = @@authorize_option_defaults.merge(options)
      set_options options
      handle_cavv_options(options)
      set_fields(:amount => amount)
      self.type = Type::AUTHORIZE_ONLY
      run
    end

    protected

    def set_options(options)
      options.each do |key, value|
        set_fields(key => value)
      end
    end

  end

end