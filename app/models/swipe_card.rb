#encoding: utf-8
class SwipeCard < ActiveRecord::Base
  set_table_name :swipe_card
  belongs_to :partner, :class_name => User

  attr_accessible :id,
                  :track_1, :track_2, :track_3,
                  :track_1_ds, :track_2_ds, :track_3_ds,
                  :track_1_masked, :track_2_masked, :track_3_masked,
                  :masked_tracks, :sdk_version, :encode_type,
                  :magne_print, :device_serial, :session_id,
                  :nap, :exp_date, :ksn,
                  :first_name, :middle_name, :last_name,
                  :partner_id, :partner
end