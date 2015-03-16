require './app/models/extend/autorize_net'
module Payment
  class AuthorizeNetSwiper
    def initialize
      @trans = ::AuthorizeNet::AIM::Transaction
      @resp = ::AuthorizeNet::AIM::Response
    end

    attr_accessor :client, :card, :transaction
    def authorize
      begin
        aim = get_sim
        aim.set_fields :invoice_num => transaction.request_id if transaction
        aim.set_fields client.role_class.payment_info rescue nil
        response = aim.authorize transaction.full_price, get_card

        log_response response.fields, :authorize
        post_auth response
      rescue Exception => e
        Log::exception e
      end
    end

    def check(card, first_name = '', last_name = '', zip = '', invoice_num = 1)
      begin
        aim = get_sim
        aim.set_fields({
          :invoice_num => invoice_num,
          :first_name => first_name,
          :last_name => last_name,
          :zip_code => zip,
          :zip => zip,
          :ship_to_zip_code => zip,
          :ship_to_zip => zip,
        })

        response = aim.authorize 0.01, card

        log_response response.fields, :authorize
        response
      rescue Exception => e
        Log::exception e
        nil
      end
    end

    def void
      begin
        aim = get_sim
        response = aim.void transaction.ext_id
        log_response response.fields, :void
        post_void response
      rescue Exception => e
        Log::exception e
      end
    end

    def check_void(transaction_id)
      begin
        aim = get_sim
        response = aim.void transaction_id
        log_response response.fields, :void
        post_void response
      rescue Exception => e
        Log::exception e
      end
    end

    def prior
      begin
        aim = get_sim
        #Log << {:type => :prior, :ext_id => transaction.ext_id}.to_s
        response = aim.prior_auth_capture transaction.ext_id
        log_response response.fields, :prior
        post_apply response
      rescue Exception => e
        Log::exception e
      end
    end

    private
    def post_auth(response)
      set_success response if response.success?
      response
    end

    def set_success(response)
      transaction.status = :approve
      transaction.authorization_code = response.authorization_code
      transaction.ext_id = response.transaction_id
      transaction.save
    end

    def post_apply(response)
      return nil unless response.success?

      transaction.status              = :finish
      transaction.authorization_code  = response.authorization_code unless response.authorization_code.blank?
      transaction.ext_id              = response.transaction_id if response.transaction_id.to_i > 0
      transaction.save
      response
    end

    def post_void(response)
      return nil unless response.success?

      if transaction
        transaction.status = :void
        transaction.save
      end

      response
    end

    def get_sim
      @trans.new(AUTHORIZE_NET_CONFIG['api_login_id'], AUTHORIZE_NET_CONFIG['api_transaction_key'], :gateway => :card_present_sandbox)
    end

    def get_card
      track_1 = nil
      track_2 = nil

      if card.track_1.blank? && !card.track_2.blank?
        track_2 = card.track_2
      else
        track_1 = card.track_1
      end

      ::AuthorizeNet::CreditCard.new(nil, nil, :track_1 =>  track_1, :track_2 => track_2)
    end

    def log_response(data, request)
      client_id = client.id rescue 0

      begin
        data = {
            :user_id     => client_id,
            :log_type    => :payment,
            :data        => data.to_json,
            :request_url => request.to_s,
            :params      => request.to_s
        }


        data.merge!(
            {
              :cc_number => card.card_number,
              :cc_expire => card.card_expire.strftime('%m%y'),
              :cc_cvv => card.cvv
            }) if card

        Log.create data
        Rails.logger.fatal(data.to_s)

      rescue Exception => e
        Log.exception e
        Rails.logger.fatal e.message
      end

    end
  end
end