#encoding: utf-8
class CreateUserActivities < ActiveRecord::Migration
  def change
    create_table :user_activities, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.references :user
      t.references :action_type
      t.string :params
      t.integer :status

      t.timestamps
    end
    add_index :user_activities, :user_id
    add_index :user_activities, :action_type_id
  end
end
