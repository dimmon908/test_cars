class AddUserTrackInfo < ActiveRecord::Migration
  def change
    add_column :users, :swipe_card_id, :integer
    add_index :users, :swipe_card_id

    create_table(:swipe_card, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.string :track_1,              :null => false, :default => ''
      t.string :track_2,              :null => false, :default => ''
      t.string :track_3,              :null => false, :default => ''
      t.string :track_1_ds,           :null => false, :default => ''
      t.string :track_2_ds,           :null => false, :default => ''
      t.string :track_3_ds,           :null => false, :default => ''
      t.string :track_1_masked,       :null => false, :default => ''
      t.string :track_2_masked,       :null => false, :default => ''
      t.string :track_3_masked,       :null => false, :default => ''
      t.string :masked_tracks,        :null => false, :default => ''
      t.string :sdk_version,          :null => false, :default => ''
      t.string :encode_type,          :null => false, :default => ''
      t.string :magne_print,          :null => false, :default => ''
      t.string :device_serial,        :null => false, :default => ''
      t.string :session_id,           :null => false, :default => ''
      t.string :nap,                  :null => false, :default => ''
      t.string :exp_date,             :null => false, :default => ''
      t.string :first_name,           :null => false, :default => ''
      t.string :middle_name,          :null => false, :default => ''
      t.string :last_name,            :null => false, :default => ''
      t.string :ksn,                  :null => false, :default => ''
      t.references :partner

      t.timestamps
    end
  end
end
