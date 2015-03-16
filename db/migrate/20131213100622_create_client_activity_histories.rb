class CreateClientActivityHistories < ActiveRecord::Migration
  def change
    create_table :client_activity_histories do |t|
      t.references :user
      t.datetime :date
      t.string :user_type, :limit => 10
      t.string :action, :limit => 20
      t.text :request
      t.text :response
      t.string :device_id
      t.string :device_system, :limit => 15

      t.timestamps
    end
    add_index :client_activity_histories, :user_id
    add_index :client_activity_histories, :user_type, :length => 10
    add_index :client_activity_histories, :action, :length => 20
    add_index :client_activity_histories, [:device_id, :device_system]
  end
end
