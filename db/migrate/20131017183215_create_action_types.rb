#encoding: utf-8
class CreateActionTypes < ActiveRecord::Migration
  def change
    create_table :action_types, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :internal_name
      t.integer :scope

      t.timestamps
    end
  end
end
