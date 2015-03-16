module Trip
  module StatusChanges
    def active?
      ::Request::ACTIVE.include?(self.status.to_sym)
    end

    def active_tab?
      self.active? || (self.past? && self.date > ::Time.now.beginning_of_day)
    end

    def past?
      ::Request::PAST.include?(self.status.to_sym)
    end

    def cant_canceled?
      self.canceled? || self.finished? || self.error?
    end

    def instant?
      self.status.to_sym == :instant
    end

    def future?
      self.status.to_sym == :future
    end

    def accepted?
      self.status.to_sym == :accept
    end

    def waiting?
      self.status.to_sym == :waiting
    end

    def error?
      self.status.to_sym == :error
    end

    def canceled?
      self.status.to_sym == :canceled
    end

    def started?
      self.status.to_sym == :started
    end

    def finished?
      self.status.to_sym == :finished
    end

    def instant!(save = false)
      self.status = :instant

      ::DriverRequestHistory::add self
      self.save :validate => false if save

      ::CheckRequestBroadcast::start_me_up id
    end

    def future!(save = false)
      self.status = :future
      self.save :validate => false if save
    end

    def accepted!(save = false)
      self.status = :accept
      self.accepted = ::Time.now
      ::DriverRequestHistory::add self
      self.save :validate => false if save
    end

    def waiting!(save = false)
      self.status = :waiting
      ::DriverRequestHistory::add self
      self.save :validate => false if save
    end

    def error!(save = false)
      self.status = :error
      ::DriverRequestHistory::add self
      self.save :validate => false if save
    end

    def client_canceled?
      status.to_sym == :canceled && cancelled_user && ::Role::client?(cancelled_user)
    end
    def driver_canceled?
      status.to_sym == :canceled && cancelled_user && ::Role::driver?(cancelled_user)
    end
    def admin_canceled?
      status.to_sym == :canceled && cancelled_user && ::Role::admin?(cancelled_user)
    end
    def unauth_canceled!(save = false)
      self.status = 'unauth'
      self.cancelled = ::Time.now
      ::DriverRequestHistory::add self
      self.save :validate => false if save

      if self.get_transaction
        self.transaction.base = 0
        self.transaction.full_price!
      end
    end
    def canceled!(save = false)
      self.status = :canceled
      self.cancelled = ::Time.now
      ::DriverRequestHistory::add self
      self.save :validate => false if save

      if get_transaction
        transaction.base = 0
        transaction.full_price!
      end
    end
    def client_canceled!(user_id)
      self.cancelled_user_id = user_id

      if before_cancel_time.to_f <= 0 && get_transaction
        transaction.penalty = ::Configurations[:cancel_fee_amount].to_f
      end

      return nil unless canceled!(true)

      if driver
        notify_driver
        driver.status = ::Chauffeur::Status::ACTIVE
        driver.save :validate => false
      end

      true
    end

    def started!(save = false)
      self.status = :started
      self.start = Time.now
      ::DriverRequestHistory::add self
      self.save :validate => false if save
    end

    def finished!(save = false)
      self.status = :finished
      self.end = ::Time.now
      self.real_time = ::Time.now.to_i - start.to_i unless params['updated_end_time']
      params['updated_end_time'] = true

      #regenerate_distance
      ::DriverRequestHistory::add self
      self.save :validate => false if save
      calculate_rate

      ::DelayPayment::delay_pay id
      true
    end

    def refund!(save = false)
      self.status = :refund
      ::DriverRequestHistory::add self
      self.save :validate => false if save
    end

    def confirm
      ::AddressBook.create[:user_id => user_id, :address => from, :public_name => from, :show => 0] unless AddressBook::where(:user_id => user_id, :address => from).any?
      to.each do |to|
        ::AddressBook.create[:user_id => user_id, :address => to, :public_name => to, :show => 0] unless AddressBook::where(:user_id => user_id, :address => to).any?
      end

      self.booked = Time.now
      save

      ::CheckRequestBroadcast::start_me_up(self.id) if Trip::Status::instant?(self)
      #self.created_sms
    end

  end
end
