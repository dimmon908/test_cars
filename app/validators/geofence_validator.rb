class GeofenceValidator < ActiveModel::EachValidator
  # @param [Request] record
  def validate_each(record, attribute, value)
    return unless record.id.nil?

    center_coordinate = Configurations[:trip_pu_center]
    return unless center_coordinate
    max_distance = Configurations[:trip_pu_center_distance].to_f
    return if max_distance.blank?

    distance = ::Location.distance_between_coordinates(record.from_coord, center_coordinate)
    distance_miles = HelperTools.meters_to_miles distance

    if distance_miles > max_distance
      record.errors[:no_driver] << I18n.t('activerecord.errors.models.request.attributes.from.geofence')
    end
  end
end