#encoding: utf-8
class CheckController < ApplicationController
  respond_to :json

  def email
    user = User::find_by_email params[:value]
    if user
      render :json => {:status => :error, :message => I18n.t('model.errors.custom.user_email') }, :status => '404'
    else
      render :json => {:status => :ok }
    end
  end

  def phone
    if params[:id]
      if User::where('phone = ? and id != ?',params[:value], params[:id]).any?
        render :json => {:status => :error, :message => I18n.t('model.errors.custom.user_phone') }, :status => '404'
        return
      end
    else
      if User::where('phone = ?',params[:value]).any?
        render :json => {:status => :error, :message => I18n.t('model.errors.custom.user_phone') }, :status => '404'
        return
      else

      end
    end
    render :json => {:status => :ok }
  end

  def request_status
    status = params[:value]
    user_id = params[:user_id]
    date = params[:date]

    if status && User::where(:user_id => user_id).any?
      if User::find(user_id).role? :personal
        return render :json => {:status => :error, :message => I18n.t('model.errors.custom.exist_instant_request') }, :status => '404' if Request::where("`user_id` = ? AND STR_TO_DATE(`date`, '%Y-%c-%d %H:%i') < ?", user_id, DateTime.strptime(date, Request::DATE_FORMAT)).any?
      end
    end
    render :json => {:status => :ok }
  end

  def request_status_time
=begin
    time = params[:value]
    status = params[:status]
    min = Configurations[:instant_request_time]
    date = DateTime.strptime((time.to_i/1000).to_s, '%s')

    if status == 'future' && date < (Time.now + min.minute)
      render :json => {
          :status => :error,
          :message => I18n.t('model.errors.custom.future_request_min_period', :min => min)
      }, :status => '404'
      return
    end
=end

    render :json => {:status => :ok }
  end

  def driver_available
    status = params[:status]
    if status == 'instant' && !Driver::available.any?
      render :json => {
          :status => :error,
          :message => I18n.t('activerecord.errors.models.request.attributes.status.driver_available')
      }, :status => '404'
      return
    end

    render :json => {:status => :ok }
  end

  def future_vehicle
    begin
      date = DateTime.strptime(params[:date], '%s')
      if Vehicle::future_validation date
        render json: {:status => :ok}
      else
        render json: {:status => :error}
      end
    rescue Exception => e
      render json: {:status => :error, :message => e.to_s}
    end

  end

  def promo_code_unique
    data = {:status => :error, :message => I18n.t('activerecord.errors.models.promo_code.attributes.code.promo_code_unique')}
    if params[:id]
      render :json => data and return if PromoCode::where('id != ? and code = ?', params[:id], params[:value]).any?
    else
      render :json => data and return if PromoCode::where('code = ?', params[:value]).any?
    end

    render :json => {:status => :ok }
  end

  def promo_name_unique
    data = {:status => :error, :message => I18n.t('activerecord.errors.models.promo_code.attributes.code.promo_name_unique')}
    if params[:id]
      render :json => data and return if PromoCode::where('id != ? and name = ?', params[:id], params[:value]).any?
    else
      render :json => data and return if PromoCode::where('name = ?', params[:value]).any?
    end

    render :json => {:status => :ok }
  end

  def valid_pu
    begin
      lat = params[:lat]
      lng = params[:lng]

      center_coordinate = Configurations[:trip_pu_center]
      max_distance = Configurations[:trip_pu_center_distance].to_f
      distance = ::Location.distance_between_coordinates({'lat' => lat, 'lng' => lng}, center_coordinate)
      distance_miles = HelperTools.meters_to_miles distance

      if distance_miles <= max_distance
        render json: {:status => :ok}
      else
        render json: {:status => :error, :message => t('activerecord.errors.models.request.attributes.from.geofence')}
        Log << {:distance_miles => distance_miles, :max_distance => max_distance}.to_s
      end
    rescue Exception => e
      render json: {:status => :error, :message => t('activerecord.errors.models.request.attributes.from.geofence')}
      Log.exception e
    end
  end

  def valid_credit_card
    begin
      card_number =params[:number]
      card_date = params[:date]
      card_cvv = params[:cvv]
      first_name = params[:first_name]
      last_name = params[:last_name]
      # email = params[:email]
      # phone = params[:phone]
      zip = params[:zip]

      card = ::AuthorizeNet::CreditCard.new(card_number, card_date, :card_code =>  card_cvv)
      bill = Payment::AuthorizeNet.new

      invoice_num = session[:invoice_num]
      invoice_num ||= 1

      response = bill.check card, first_name, last_name, zip, invoice_num

      invoice_num += 1
      session[:invoice_num] = invoice_num

      if response.success?
        bill.check_void response.transaction_id
        render json: {:status => :ok}
      else
        render json: {:status => :error, :message => response.response_reason_text} and return if response.response_reason_code == '2'
        render json: {:status => :error, :message => t('errors.messages.declined_cc')}
      end
    rescue Exception => e
      Log.exception e
      render json: {:status => :error, :message => t('errors.messages.invalid_cc_exc')}
    end

  end
end
