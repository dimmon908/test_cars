#encoding: utf-8
ActiveRecord::Base.connection.execute('TRUNCATE TABLE `configurations`')
ActiveRecord::Base.connection.execute('TRUNCATE TABLE `config_groups`')
Configurations[:business_types]= { value: MessagePack.pack(%w(small medium large)), area: :business }
Configurations[:year_in_business]= { value: MessagePack.pack((1..20).to_a), area: :business }
Configurations[:business_employers]= { value: MessagePack.pack(%w(<10 <50 <1000 <10000)), area: :business }
Configurations[:business_requests]= { value: MessagePack.pack(%w(10 20 30 50 100)), area: :business }

Configurations[:credit_card_year_range]= { value: MessagePack.pack(10), area: :business }

Configurations[:fuel_types]= { value: MessagePack.pack(%w(Petrol Diesel Biodiesel Autogas Ethanol Blend Hybrid)), area: :car }
Configurations[:manufacturers]= { value: MessagePack.pack(%w(Mercedes Audi BMW Opel Porsche Volkswagen)), area: :car }
Configurations[:models]= { value: MessagePack.pack(%w(GL100 GL200 GL300 GL400 GL500 GL600)), area: :car }
Configurations[:model_year]= { value: MessagePack.pack((2000..2013).to_a), area: :car}
Configurations[:car_colors]= { value: MessagePack.pack(%w(black white red blue yellow green)), area: :car}
Configurations[:car_passengers]= { value: MessagePack.pack(%w(5 6 7 8)), area: :car}

Configurations[:genders]= { value: MessagePack.pack(%w(M F)), area: :general }
Configurations[:age_groups]= { value: MessagePack.pack(%w(<18 <21 <25 <30 <40 <50 <60 60+)), area: :general }
Configurations[:admin_email]= { value: MessagePack.pack('dimmon908@gmail.com'), area: :general }

Configurations[:passengers_per_request]= { value: MessagePack.pack((1..8).to_a), area: :request }
Configurations[:luggage_per_request]= { value: MessagePack.pack((1..8).to_a), area: :request }
Configurations[:max_notify_count]= { value: MessagePack.pack(5), area: :request }
Configurations[:min_notify_count]= { value: MessagePack.pack(3), area: :request }
Configurations[:min_notify_count]= { value: MessagePack.pack(3), area: :request }
Configurations[:default_notify_trigger]= { value: MessagePack.pack('phone'), area: :request }
Configurations[:instant_request_time]= { value: MessagePack.pack(45), area: :request }
Configurations[:future_request_pickup_time]= { value: MessagePack.pack(45), area: :request }
Configurations[:future_request_sprinter_time]= { value: MessagePack.pack(24), area: :request }
Configurations[:future_request_minimum_response_time_window]= { value: MessagePack.pack(15), area: :request }
Configurations[:future_request_admin_call_time]= { value: MessagePack.pack(25), area: :request }

Configurations[:rate_per_meter]= { value: MessagePack.pack(1.05), area: :request }
Configurations[:rate_per_mile]= { value: MessagePack.pack(4), area: :request }
Configurations[:rate_per_minute]= { value: MessagePack.pack(1.05), area: :request }
Configurations[:rate_per_wait_minute]= { value: MessagePack.pack(0.35), area: :request }
Configurations[:min_miles_for_minute]= { value: MessagePack.pack(11), area: :request }

Configurations[:business_premium_added]= { value: MessagePack.pack(0.15), area: :request }
Configurations[:last_address]= { value: MessagePack.pack(10), area: :request }
Configurations[:default_map_marker]= { value: MessagePack.pack('[{"lat":"37.776651","lng":"-122.41976"}]'), area: :request }
Configurations[:default_map_zoom]= { value: MessagePack.pack(12), area: :request }
Configurations[:default_map_latitude]= { value: MessagePack.pack(37.776651), area: :request }
Configurations[:default_map_longitude]= { value: MessagePack.pack(-122.41976), area: :request }

Configurations[:cancel_no_fee_time] = { value: MessagePack.pack(8.minute), area: :request }
Configurations[:cancel_future_no_fee_time] = { value: MessagePack.pack(5.minute), area: :request }

Configurations[:cancel_fee_amount]= { value: MessagePack.pack(10.0), area: :request }
Configurations[:cancel_fee_amount_after_accept]= { value: MessagePack.pack(15.0), area: :request }
Configurations[:cancel_fee_amount_after_accept_percent]= { value: MessagePack.pack(20.0), area: :request }
Configurations[:max_rate_over_estimated]= { value: MessagePack.pack(20.0), area: :request }
Configurations[:no_destination_fare]= { value: MessagePack.pack(50.0), area: :request }
Configurations[:minimum_fare]= { value: MessagePack.pack(15.0), area: :request }
Configurations[:finish_transaction_timeout]= { value: MessagePack.pack(5), area: :request }

Configurations[:max_car_photos]= { value: MessagePack.pack(3), area: :car }

Configurations[:default_driver_password]= { value: MessagePack.pack('12345'), area: :driver }
Configurations[:default_expire_token_date]= { value: MessagePack.pack(1.day), area: :driver }

Configurations[:default_kiosk_user_password] = { value: MessagePack.pack('kiosk_2014'), area: :kiosk }

Configurations[:default_account]= { value: MessagePack.pack('jeremy@musai.co'), area: :notification }
Configurations[:default_password]= { value: MessagePack.pack('Ampersand'), area: :notification }

Configurations[:twilio_sid]= { value: MessagePack.pack('ACf890929de15716ba6d25e9a6f9a4671f'), area: :notification }
Configurations[:twilio_token]= { value: MessagePack.pack('9bfd238a96364f499c4ab34efac3d195'), area: :notification }

Configurations[:test_twilio_sid]= { value: MessagePack.pack('ACf66d7d9ca3da191581fa6b4c483ae95d'), area: :notification }
Configurations[:test_twilio_token]= { value: MessagePack.pack('084120513fe40ab109218b97798c8b67'), area: :notification }

Configurations[:twilio_from_number]= { value: MessagePack.pack('+14153736712'), area: :notification }

Configurations[:dashboard_last_request_count] = { value: MessagePack.pack(2), area: :admin }
Configurations[:per_pages_values] = { value: MessagePack.pack([10, 15, 20, 30, 35, 50, 100]), area: :admin }
Configurations[:admin_display_messages] = { value: MessagePack.pack(30), area: :admin }

Configurations[:online_timeout] = { value: MessagePack.pack(5), area: :driver }

Configurations[:trip_pu_center] = { value: MessagePack.pack({:lat => 37.773329, :lng =>  -122.471060}), area: :request }
Configurations[:trip_pu_center_distance] = { value: MessagePack.pack(15.5), area: :request }