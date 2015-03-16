module Report
  class Driver < Report::Base
    HANDLERS = {
        :driver => lambda {|trip| trip.driver_id },
        :car => lambda {|trip| trip.car.place_number },
        :start => lambda {|trip| trip.start  },
        :end => lambda {|trip| trip.end },
        :breaks => lambda {|trip|
          DriverActivityHistory::where('driver_id = ? AND status = ? and created_at > ? && created_at < ?',
                                       trip.driver_id,
                                       Chauffeur::Status::DISABLED,
                                       @from, @to).count
        },
        :gratuity => lambda {|driver|
          Transaction::where('request_id in ? AND gratuity > 0',
                             Request::where('driver_id = ? AND date >= ? AND date <= ? and status = ?',
                                            driver.id, @from, @to, :finished
                             ).collect{|r| r.id}
          ).sum(:gratuity)
        },
        :roting => lambda {|trip| '' }
    }

    attr_accessor :driver, :car, :start, :end, :breaks, :roting, :gratuity

    def rows
      Driver
    end


    def fill_handlers(hand)
      hand[:driver]   = true if driver
      hand[:car]      = true if car
      hand[:start]    = true if start
      hand[:end]      = true if self.end
      hand[:breaks]   = true if breaks
      hand[:gratuity] = true if gratuity
      hand[:roting]   = true if roting
    end

    def columns
      columns = []
      columns << I18n.t('admin.reports.driver_id') if driver
      columns << I18n.t('admin.reports.car') if car
      columns << I18n.t('admin.reports.start') if start
      columns << I18n.t('admin.reports.end') if self.end
      columns << I18n.t('admin.reports.breaks') if breaks
      columns << I18n.t('admin.reports.gratuity') if gratuity
      columns << I18n.t('admin.reports.roting') if roting
      columns
    end
  end
end
