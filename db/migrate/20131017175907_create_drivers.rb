#encoding: utf-8
class CreateDrivers < ActiveRecord::Migration
  def change
    create_table :drivers, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.references :user
      t.references :car
      t.string :license_number, :limit => 50
      t.datetime :license_expore
      t.boolean :gender
      t.integer :age_group
      t.string :second_lang, :limit => 30
      t.string :temp_password, :limit => 50
      t.integer :status
      t.boolean :enabled
      t.datetime :status_changed

      t.timestamps
    end
    add_index :drivers, :user_id
    add_index :drivers, :car_id
  end
end
