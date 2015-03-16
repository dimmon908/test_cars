module CarExt
  module ExportCsv
    extend ActiveSupport::Concern

    included do

      # capabilities to export to CSV
      comma do
        id
        place_number
        manufacturer
        model_name
        model_year
        color
        passenger_capacity
        fuel_type
        created_at
        updated_at
        status
        vehicle             :name => "Vehicle Name"
      end


    end

  end
end