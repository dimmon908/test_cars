module Report
  class Refund < Report::Base
    HANDLERS = {
        :trip => lambda {|trip| trip.id },
        :driver => lambda {|trip| trip.driver_id },
        :car => lambda {|trip| trip.car.place_number },
        :user => lambda {|trip| trip.user.full_name },
        :business => lambda {|trip| trip.user.business_info.business_name if trip.user.business_info },
        :full_price => lambda {|trip| trip.charged_price },
        :gratuity => lambda {|trip| trip.transaction.gratuity },
        :refund => lambda {|trip| trip.transaction.refund },
    }

    attr_accessor :trip, :driver, :car, :user, :business, :full_price, :gratuity, :refund

    def rows
      Request::where('date >= ? AND date <= ? and status = ?', @from, @to, :refund)
    end
    def fill_handlers(hand)
      hand[:trip]       = true if trip
      hand[:driver]     = true if driver
      hand[:car]        = true if car
      hand[:user]       = true if user
      hand[:business]   = true if business
      hand[:full_price] = true if full_price
      hand[:gratuity]   = true if gratuity
      hand[:refund]     = true if refund
    end

    def columns
      columns = []
      columns << I18n.t('admin.reports.trip_id') if trip
      columns << I18n.t('admin.reports.driver_id') if driver
      columns << I18n.t('admin.reports.car') if car
      columns << I18n.t('admin.reports.user') if user
      columns << I18n.t('admin.reports.business') if business
      columns << I18n.t('admin.reports.full_price') if full_price
      columns << I18n.t('admin.reports.gratuity') if gratuity
      columns << I18n.t('admin.reports.refund_amount') if refund
      columns
    end
  end
end
