#encoding: utf-8
class CreateUserRoles < ActiveRecord::Migration
  def change
    create_table :roles, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :internal_name
      t.text :description
      t.timestamps
    end
  end
end
