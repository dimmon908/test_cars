#encoding: utf-8
class CreateTableUserProfile < ActiveRecord::Migration
  def change
    create_table :user_profile, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.references :user
      t.string :first_name
      t.string :last_name
      t.string :zip_code, :limit => 10
      t.timestamps
    end

    change_table :users do |t|
      t.remove :firstname, :last_name, :zip_code
    end
  end
end
