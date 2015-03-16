module DriverExt
  module ExportCsv
    extend ActiveSupport::Concern

    included do

      # capabilities to export to CSV
      comma do
        id
        user            :username => "Username"
        car             :model_name => "Car Model Name"
        license_number
        license_expore
        gender
        age_group
        second_lang
        temp_password
        status
        enabled
        status_changed
        created_at
        updated_at
        latitude
        longitude
        gmaps
        rate
        exp
        alt_phone
        birthdate
        device_id
        online
        device
      end


    end

  end
end