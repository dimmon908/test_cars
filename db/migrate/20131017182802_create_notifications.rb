#encoding: utf-8
class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :internal_name
      t.text :body
      t.string :title
      t.integer :type
      t.integer :scope
      t.integer :react
      t.integer :lifetime

      t.timestamps
    end
  end
end
