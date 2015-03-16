#encoding: utf-8
class SessionController < ApplicationController
  def save
    session[params[:key]] = params[:value]
    render json: {:status => :ok}
  end

  def get
    if session[params[:key]].nil?
      render json: {:status => :error, :value => false}
    else
      render json: {:status => :ok, :value => session[params[:key]]}
    end

  end
end
