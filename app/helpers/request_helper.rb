#encoding: utf-8
module RequestHelper

  # @param [Request] request
  # @param [Array] vehicles
  # @param [Fixnum] id
  # @return [Boolean]
  def self.future_vehicle?(request, vehicles, id)
    vehicles.include?(id)  && (Trip::Status::instant? request || !Vehicle::future_validation(request.datetime_date))
  end
end
