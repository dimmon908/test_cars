class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      t.datetime :date
      t.references :user
      t.string :name, :limit => 30
      t.string :hash, :limit => 50

      t.timestamps
    end
    add_index :reminders, :user_id
    add_index :reminders, :name
  end
end
