module Included
  module Transaction
    # @return [::Transaction]
    def transaction
      @transaction
    end

    def get_transaction
      return @transaction if @transaction
      return nil unless user && id

      if ::Transaction::where(:request_id => id).any?
        @transaction = ::Transaction.find_by_request_id(id)
      else
        @transaction = ::Transaction.create({
                                              :user => user,
                                              :partner_id => user.partner_id,
                                              :request => self,
                                              :base => rate,
                                              :payment => payment
                                          })
      end

      transaction
    end

    def calculate_wait_time
      res = params['wait_time']
      if res.blank?
        begin
          started_time = DriverRequestHistory.started(id).first
          waiting_time = DriverRequestHistory.waiting(id).first
          res = started_time.created_at - waiting_time.created_at if started_time && waiting_time
        rescue Exception => e
          Rails.logger.error e.message
        end
        res ||= 0
        params['wait_time'] = res if res > 0
      end
      res
    end

    def check_real_time
      if real_time && params['updated_end_time'].blank?
        self.real_time = self.end.to_i - self.start.to_i
        params['updated_end_time'] = true
      end
    end

    def charged_price
      if get_transaction
        return transaction.charged unless transaction.charged.blank?
        return transaction.full_price
      end
      nil
    end

    def calculate_rate
      rate = Fares.get_special_rate from, to
      if rate
        if get_transaction
          transaction.base  = rate
          transaction.promo = 0
          transaction.full_price!
        end

        self.rate = rate
        return rate
      end

      distance = real_distance.blank? ? self.distance.to_f : real_distance.to_f
      time     = real_time.blank? ? self.time.to_f : real_time.to_f

      return 0 if distance.blank?
      #wait_time = calculate_wait_time

      rate     = Fares::calculate distance, time, vehicle.rate, vehicle#, wait_time
      discount = promo_code.calc_discount rate if promo_code
      discount ||= 0

      if get_transaction
        transaction.base  = rate
        transaction.promo = discount
        transaction.full_price!
      end

      rate -= discount

      rate = 0 if rate < 0

      self.rate = rate if ((self.real_distance.blank? && self.real_time.blank?) || self.rate.blank?)

      params['estimated_rate'] = rate if !real_time.blank? && !real_distance.blank?

      rate
    end

    def estimated_rate
      return params['estimated_rate'] if params['estimated_rate'].to_i > 0

      rate = Fares.get_special_rate from, to
      return rate if rate

      return 0 if self.distance.blank?

      distance = self.distance.to_f
      time     = self.time.to_f

      rate     = Fares::calculate distance, time, vehicle.rate, vehicle
      discount = promo_code.calc_discount rate if promo_code
      discount ||= 0

      rate      -= discount
      rate = 0 if rate < 0

      params['estimated_rate'] = rate
      save

      rate
    end

  end
end
