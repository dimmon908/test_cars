module Chauffeur
  class Status
    ACTIVE = :active
    DISABLED = :disabled
    ACCEPTED = :accepted
    WAITING = :waiting
    BOOKED = :booked

    DRIVER_BOOKED = [BOOKED, ACCEPTED, WAITING]

    # @param [Driver] driver
    def self.booked?(driver)
      DRIVER_BOOKED.include?(driver.status.to_sym)
    end
  end
end
