
module PersonalAccountExt
  module ExportCsv
    extend ActiveSupport::Concern

    included do

      # capabilities to export to CSV
      comma do
        id
        email
        sign_in_count
        current_sign_in_at
        last_sign_in_at
        current_sign_in_ip
        last_sign_in_ip
        created_at
        updated_at
        username
        phone
        status
        can_receive_request
        old_data
        card_id
        role                        :internal_name => "Role"
        business_info               :name => "Name"
        approve
        partner                     :username => "username"
        api_token
        token_expire
        confirmed_at
        confirmation_sent_at
        confirmation_token
        unconfirmed_email
      end


    end

  end
end