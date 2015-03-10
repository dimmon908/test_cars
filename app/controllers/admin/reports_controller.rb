#encoding: utf-8
require 'query_report/helper'
module Admin
  class ReportsController < ApplicationController
    include QueryReport::Helper
    before_filter :authenticate_user!
    respond_to :js, :html, :pdf, :csv
    layout :admin_layout

    def daily_report
      check_auth
      @tab = :report

      requests = Request.select("requests.*, concat(user_profile.first_name, ' ',user_profile.last_name) as user_name")
      .from('requests, user_profile')
      .where('user_profile.user_id = requests.user_id')

      reporter(requests) do

        filter :booked, type: :date, default: [1.day.ago.to_date.to_s(:db), Date.current.to_s(:db)]
        filter :user_name, type: :text do |query, name|
          query.where('user_profile.first_name like ? or user_profile.last_name like ?', "%#{name}%", "%#{name}%")
        end

        column :id
        column 'user name' do |request|
          begin
            "#{request.user.first_name} #{request.user.last_name}"
          rescue
            'user no longer registered'
          end
        end
        column :driver_id do |request|
          begin
            if request.driver_id
              "#{request.driver.first_name} #{request.driver.last_name}"
            else
              ''
            end
          rescue
            'driver no longer registered'
          end
        end
        column :vehicle_id
        column :status
        column :from
        column :to
        column 'estimated rate' do |request|
          number_to_currency request.rate
        end
        column 'final rate' do |request|
          if Trip::Status.finished? request
            number_to_currency request.charged_price
          else
            ''
          end
        end
        column :comment
        column :promo_code_id do |request|
          if request.promo_code_id
            request.promo_code.code
          else
            ''
          end
        end
        column :payment_options
        column :booked
        column :start
        column :end
        column :real_time
        column :cancelled
        column :partner_id
        column :cancelled_user_id
      end
    end

    def future_report
      check_auth
      @tab = :report
      requests = Request::where("status = 'future'").order('date DESC')

      reporter(requests) do
        column :user_id
        column "user name" do |request|
          begin
            @user_profile = User.find(request[:user_id])
            "#{@user_profile.first_name} #{@user_profile.last_name}"
          rescue
            "user no longer registered"
          end
        end
        column :driver_id do |request|
          begin
            if request.driver_id
              "#{request.driver.first_name} #{request.driver.last_name}"
            else
              ''
            end
          rescue
            'driver no longer registered'
          end
        end
        column :vehicle_id
        column :status
        column :from
        column :to
        column 'estimated rate' do |request|
          number_to_currency request.rate
        end
        column :comment
        column :promo_code_id do |request|
          if request.promo_code_id
            request.promo_code.code
          else
            ''
          end
        end
        column :payment_options
        column :booked
        column :start
        column :end
        column :real_time
        column :cancelled
        column :partner_id
        column :cancelled_user_id
      end
    end

    def driver_report
      check_auth
      @tab = :report
      requests = Request.select("requests.*, concat(user_profile.first_name, ' ',user_profile.last_name) as driver_name")
      .from("requests, user_profile")
      .where("driver_id is not null and user_profile.user_id = requests.driver_id")

      reporter(requests.scoped) do
        filter :booked, type: :date, default: [1.day.ago.to_date.to_s(:db), Date.current.to_s(:db)]
        filter :driver_name, type: :text do |query, name|
          query.where("user_profile.first_name like ? or user_profile.last_name like ?", "%#{name}%", "%#{name}%")
        end

        column :user_id
        column :driver_name
        column :status
        column :from
        column :to
        column 'estimated rate' do |request|
          number_to_currency request.rate
        end
        column 'final rate' do |request|
          if Trip::Status.finished? request
            number_to_currency request.charged_price
          else
            ''
          end
        end
        column :comment
        column :time do |request|
          "#{(request.time/60).to_i} min"
        end
        column :distance do |request|
          "#{HelperTools.meters_to_miles request.distance} ml"
        end
        column :booked
        column :start
        column :end
        column :real_time
        column :cancelled
        column :partner_id
        column :cancelled_user_id
      end
    end

    def tips_report
      check_auth
      @tab = :report
      requests = Request.select("requests.*, concat(user_profile.first_name, ' ',user_profile.last_name) as driver_name")
      .from("requests, user_profile")
      .where("driver_id is not null and user_profile.user_id = requests.driver_id")
      .group("driver_id")

      reporter(requests.scoped) do
        filter :driver_name, type: :text do |query, name|
          query.where("user_profile.first_name like ? or user_profile.last_name like ?", "%#{name}%", "%#{name}%")
        end

        column :driver_id
        column :driver_name
        column "tips" do |request|
          begin
            @transactions = Transaction.find_by_sql("select sum(gratuity) as tips from transactions group by user_id having user_id=#{request[:driver_id]}")
            @transactions[0]['tips']
          rescue
            "0"
          end
        end
      end
    end

    def business_report
      check_auth
      @tab = :report
      requests = Request.select("requests.*, concat(user_profile.first_name, ' ',user_profile.last_name) as user_name")
      .from('requests, user_profile, users')
      .where('user_profile.user_id = requests.user_id and users.id = user_profile.user_id and (users.role_id = 3 or users.role_id = 4)')

      reporter(requests) do

        filter :booked, type: :date, default: [1.day.ago.to_date.to_s(:db), Date.current.to_s(:db)]
        filter :user_name, type: :text do |query, name|
          query.where('user_profile.first_name like ? or user_profile.last_name like ?', "%#{name}%", "%#{name}%")
        end
        filter :partner_email, :type => :text do |query, name|
            partner_id = User.where('email LIKE ? and role_id = ?', "%#{name}%", Role.business.first.id).first.partner_id rescue 0
            users_ids = User.where('partner_id = ?', partner_id).collect{|user| user.id}
            query.where('requests.user_id IN (?)', users_ids)
        end

        column :user_id
        column 'user name' do |request|
          begin
            user_profile = User.find(request[:user_id])
            "#{user_profile.first_name} #{user_profile.last_name}"
          rescue
            'user no longer registered'
          end
        end
        column :driver_id do |request|
          begin
            if request.driver_id
              "#{request.driver.first_name} #{request.driver.last_name}"
            else
              ''
            end
          rescue
            'driver no longer registered'
          end
        end
        column 'Guest/friend name' do |request|
          if request.recommend?
            "#{request.recommended_first_name} #{request.recommended_last_name}"
          else
            ''
          end
        end
        column :status
        column :from
        column :to
        column 'estimated rate' do |request|
          request.rate
        end
        column 'final rate' do |request|
          if Trip::Status.finished? request
            request.charged_price
          else
            ''
          end
        end
        column :comment
        column :promo_code_id do |request|
          if request.promo_code_id
            request.promo_code.code
          else
            ''
          end
        end
        column :booked
        column :start
        column :end
        column :real_time
        column :cancelled
        column :partner_id
        column :cancelled_user_id
      end
    end

    def index
      check_auth
    end

    def new
      check_auth
      build_resource({})
      respond_with self.resource
    end

    def create
      begin
        build_resource(params[resource_name])
        if resource.save
          render json: {:status => :ok}
        else
          render json: {:status => :error, :message => resource.errors.messages }
        end
      rescue Exception => e
        log_exception e
        render json: {:status => :error, :message => e.to_s }
      end
    end

    def edit
      check_auth
      car = resource_class.find params[:id]
      if car.nil?
        redirect_to '/admin/reports'
        return
      end
      self.resource = car
      render '/admin/reports/edit'
    end

    def update
      car = resource_class.find params[:id]
      resource = params[resource_name]
      if car.nil? || resource.nil?
        render json: {:status => :error, :message => 'Invalid request'}
        return
      end
      if car.update_attributes(resource)
        render json: {:status => :ok}
      else
        render json: {:status => :error, :message => car.errors.messages}
      end
    end

    def show
      check_auth
      report = resource_class.find params[:id]
      redirect_to root_path and return unless report

      respond_to do |format|
        format.html {
          self.resource = report
          if ApplicationHelper::pdf? request
            render :layout => 'pdf_admin'
          else
            render :layout => false
      end
        }
        format.csv {
          render text: report.to_csv
        }
      end
    end

    def pdf
      check_auth
      report = resource_class.find params[:id]
      redirect_to root_path and return unless report

      self.resource = report
      render :template => '/admin/reports/show', :pdf => '/admin/reports/show', :layout => 'pdf_admin'
    end

    def destroy
      car = resource_class::find params[:id]
      car.destroy
      redirect_to root_path
    end

    def resource
      instance_variable_get(:"@#{resource_name}")
    end

    def resource=(new_resource)
      instance_variable_set(:"@#{resource_name}", new_resource)
    end

    private
    def build_resource(hash={})
      self.resource = resource_class.new(hash || {})
    end

    def resource_name
      'report'
    end

    def resource_class
      Reports
    end

    def admin_layout
      request.env['PATH_INFO'].include?('reports') ? 'reports' : 'admin'
    end

    helper_method :resource, :resource_class, :resource_name
  end
end