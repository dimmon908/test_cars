#encoding: utf-8
class PromoController < ApplicationController
  respond_to :js, :html, :json

  def check
    value = params[:code]

    user_id = params[:user_id] ? params[:user_id] : current_user.id

    render json: {:status => :ok} and return unless value

    promo = PromoCode.get_promo value

    errors = promo ? promo.check(user_id) : [I18n.t('model.errors.custom.promo_code')]

    if errors.empty?
      render json: {:status => :ok, :value => promo.value.to_i, :type => promo.promo_type.to_i, :id => promo.id}
    else
      render json: {:status => :error, :message => errors.to_s}, :status => 404
    end

  end

end
