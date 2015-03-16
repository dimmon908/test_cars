module Included
  module Distance
    # @param [Driver] driver
    def check_driver_distance(driver, options = {})
      step = options[:step] || broadcast_step
      max_distance = options[:max_distance] || broadcast_distance_by_step(step)

      calc_distance = ::Location.distance_between_coordinates(from_coord, driver.get_coordinates)

      max_distance.blank? || calc_distance < max_distance
    end

    private
    def regenerate_distance
      distance = 0
      begin
        to = self.to
        to = to.values if to.is_a? Hash
        coord2 = false

        to.each do |val|
          next if val.blank?

          coord = coord2 ? coord2 : Location.coordinates(from)

          coord2 = Location.coordinates val
          dist, time = Location.distance("#{coord[0][:lat]},#{coord[0][:lng]}", "#{coord2[0][:lat]},#{coord2[0][:lng]}")
          distance += dist
        end

        self.distance = distance
      rescue Exception => e
        Log.exception e
        self.distance = distance
      end

    end

    def check_distance
      regenerate_distance if distance.to_f < 1
    end
  end
end