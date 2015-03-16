module Trip
  class Status
    INSTANT  = :instant
    ACCEPT   = :accept
    WAITING  = :waiting
    STARTED  = :started
    CANCELED = :canceled
    FINISHED = :finished
    ERROR    = :error
    FUTURE   = :future
    REFUND   = :refund

    ACTIVE     = [STARTED, ACCEPT, WAITING, INSTANT]
    PAST       = [CANCELED, FINISHED, ERROR]


    # @param [Request] request
    def self.active?(request)
      ACTIVE.include?(request.status.to_sym)
    end

    # @param [Request] request
    def self.active_tab?(request)
      active?(request) || (past?(request) && request.date > Time.now.beginning_of_day)
    end

    # @param [Request] request
    def self.past?(request)
      PAST.include?(request.status.to_sym)
    end

    # @param [Request] request
    def self.cant_canceled?(request)
      canceled?(request) || finished?(request) || error?(request)
    end

    # @param [Request] request
    def self.instant?(request)
      request.status.to_sym == INSTANT
    end

    # @param [Request] request
    def self.future?(request)
      request.status.to_sym == FUTURE
    end

    # @param [Request] request
    def self.accepted?(request)
      request.status.to_sym == ACCEPT
    end

    # @param [Request] request
    def self.waiting?(request)
      request.status.to_sym == WAITING
    end

    # @param [Request] request
    def self.error?(request)
      request.status.to_sym == ERROR
    end

    # @param [Request] request
    def self.canceled?(request)
      request.status.to_sym == CANCELED
    end

    # @param [Request] request
    def self.started?(request)
      request.status.to_sym == STARTED
    end

    # @param [Request] request
    def self.finished?(request)
      request.status.to_sym == FINISHED
    end

    # @param [Request] request
    def self.refund?(request)
      request.status.to_sym == REFUND
    end
  end
end
