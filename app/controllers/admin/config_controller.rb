#encoding: utf-8
module Admin
  class ConfigController < ApplicationController
    before_filter :authenticate_user!
    respond_to :js, :html, :json
    layout 'admin'

    # GET /config/group
    def groups
      check_auth
      @tab = :configs
    end

    def edit
      check_auth

      @resource = Configurations.find params[:id] if params[:id]
      render :edit, :layout => false
    end

    # GET /config/group/:name
    def group
      check_auth
      @tab = :configs
    end

    # GET /config/group/list/:name
    def list
      check_auth
      @group = ConfigGroup::find_by_internal_name params[:name].page(params[:page])
      redirect_to '/admin/config/group' and return unless @group
      @keys = Configurations::find_all_by_config_groups_id @group.id
    end

    # PUT /config/group/:name
    def update_group
    end

    def update
      config = Configurations::find params[:id]
      begin
        val = eval(params[:config]['text_value'])
      rescue Exception => e
        log_exception e
        val = nil
      end

      config.text_value = val
      if val && config.save
        render json: {:status => :ok, value: config.text_value.to_s }
      else
        config.errors[:value] << t('forms.config.value.incorrect')
        render json: {:status => :error, message: t('forms.config.value.incorrect')}
      end
    end

    def config_key
    end

    def vehicle
      vehicle = Vehicle::find params[:id]
      render json: {:status => :error, :message => 'None such vehicle id'} and return unless vehicle

      Fares::change_fare(vehicle.internal_name, params[:value], current_user.id, vehicle.rate)
      vehicle.rate = params[:value]

      render json: {:status => :error, :message => vehicle.errors.messages.to_s} and return unless vehicle.save

      render json: {:status => :ok, value: vehicle.rate.to_s}
    end

    def get_vehicle
      vehicle = Vehicle::find params[:id]
      render json: {:status => :error, :message => 'None such vehicle id'} and return unless vehicle

      render json: {:status => :ok, value: vehicle.rate.to_s}
    end



    def vehicle_edit
      vehicle = Vehicle::find params[:id]
      render json: {:status => :error, :message => 'None such vehicle id'} and return unless vehicle

      render json: {
        :status => :ok,
        per_mile: vehicle.per_mile,
        per_minute: vehicle.per_minute,
      #  per_wait_minute: vehicle.per_wait_minute
      }
      #render json: {:status => :ok, per_mile: Configurations[:rate_per_mile], per_minute: Configurations[:rate_per_minute]}
    end

    def vehicle_update

      #Configurations[:rate_per_mile] = params[:per_mile]
      #Configurations[:rate_per_minute] = params[:per_minute]

      render json: {
        :status => :ok,
        per_mile: Configurations[:rate_per_mile],
        per_minute: Configurations[:rate_per_minute],
      #  per_wait_minute: Configurations[:rate_per_wait_minute]
      }

      vehicle = Vehicle::find params[:id]

      Fares::change_fare("per_mile_#{params[:id]}", params[:per_mile], current_user.id, vehicle.per_mile)
      Fares::change_fare("per_minute_#{params[:id]}", params[:per_minute], current_user.id, vehicle.per_minute)
      #Fares::change_fare("per_wait_minute_#{params[:id]}", params[:per_wait_minute], current_user.id, vehicle.per_wait_minute)

      vehicle.per_mile = params[:per_mile]
      vehicle.per_minute = params[:per_minute]
      #vehicle.per_wait_minute = params[:per_wait_minute]

      render json: {:status => :error, :message => vehicle.errors.messages.to_s} and return unless vehicle.save

      render json: {
        :status => :ok,
        per_mile: vehicle.per_mile,
        per_minute: vehicle.per_minute,
      #  per_wait_minute: vehicle.per_wait_minute
      }
    end

  end

end
