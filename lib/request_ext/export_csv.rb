module RequestExt
  module ExportCsv
    extend ActiveSupport::Concern

    included do

      # capabilities to export to CSV
      comma do
        id                      "Request Id"
        user                    :username
        driver                  :name
        vehicle                 :name
        status
        from
        date
        rate
        passengers
        luggage
        comment
        reserve_number
        promo_code              :name
        time
        payment_options
        created_at
        updated_at
        distance
        route
        eta
        booked
        start
        self.end
        accepted
        cancelled
        real_time
        partner                 :username
        cancelled_user          :name
        real_distance
      end


    end

  end
end