#encoding: utf-8
class CreateLogTypes < ActiveRecord::Migration
  def change
    create_table :log_types, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :type
      t.string :title

      t.timestamps
    end
  end
end
