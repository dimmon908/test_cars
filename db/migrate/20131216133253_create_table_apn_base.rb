class CreateTableApnBase < ActiveRecord::Migration
  def change
    create_table :apn_bases do |t|
      t.timestamps
    end
  end
end
