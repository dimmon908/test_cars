# encoding: UTF-8
class CreateTableActivateData < ActiveRecord::Migration
  def change
    create_table :activate_data, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :token
      t.string :code, :limit => 30
      t.datetime :expire
      t.references :user
      t.timestamps
    end
  end

end
