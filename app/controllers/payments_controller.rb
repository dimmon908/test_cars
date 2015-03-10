require 'bigdecimal'

class PaymentsController < ApplicationController

  layout 'authorize_net'
  helper :authorize_net

  protect_from_forgery :except => :relay_response
  
  # GET
  # The splash page.
  def index
  end
  
  # GET
  # Displays a form for selecting a coffee size.
  def select_size
  end
  
  # POST
  # Displays the order for review before proceeding to checkout.
  def review
    @size = params[:size]
    case @size
    when 'small'
      @amount = BigDecimal.new('1.99')
    when 'medium'
      @amount = BigDecimal.new('2.99')
    when 'large'
      @amount = BigDecimal.new('3.99')
    else
      redirect_to '/payments/select_size'
    end
    unless @amount.nil?
      @tax = @amount * 0.095
      @total = @amount + @tax
    end
  end
  
  # POST
  # Displays a payment form.
  def payment
    @amount = 10.00
    @sim_transaction = AuthorizeNet::SIM::Transaction.new(AUTHORIZE_NET_CONFIG['api_login_id'], AUTHORIZE_NET_CONFIG['api_transaction_key'], @amount, :relay_url => "#{request.host}/payments/relay_response")
  end

  # POST
  # Returns relay response when Authorize.Net POSTs to us.
  def relay_response
    sim_response = AuthorizeNet::SIM::Response.new(params)
    if sim_response.success?(AUTHORIZE_NET_CONFIG['api_login_id'], AUTHORIZE_NET_CONFIG['merchant_hash_value'])
      render :text => sim_response.direct_post_reply("#{request.host}/payments/receipt", :include => true)
    else
      render :text => sim_response.direct_post_reply("#{request.host}/payments/error", :include => true)
    end
  end
  
  # GET
  # Displays a receipt.
  def receipt
    sim_response = AuthorizeNet::SIM::Response.new(params)
    if sim_response.valid_md5?(AUTHORIZE_NET_CONFIG['api_login_id'], AUTHORIZE_NET_CONFIG['merchant_hash_value'])
      @transaction_id = sim_response.transaction_id
    else
      render :text => 'Sorry, we failed to validate your response. Please check that your "Merchant Hash Value" is set correctly in the config/authorize_net.yml file.'
    end
  end

  def my_response
    sim_response = AuthorizeNet::SIM::Response.new(params)

    render json: params
  end
  
  # GET
  # Displays an error page.
  def error
    sim_response = AuthorizeNet::SIM::Response.new(params)
    if sim_response.valid_md5?(AUTHORIZE_NET_CONFIG['api_login_id'], AUTHORIZE_NET_CONFIG['merchant_hash_value'])
      @reason = sim_response.response_reason_text
      @reason_code = sim_response.response_reason_code
      @response_code = sim_response.response_code
    else
      render :text => 'Sorry, we failed to validate your response. Please check that your "Merchant Hash Value" is set correctly in the config/authorize_net.yml file.'
    end
  end

end