class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :user
      t.references :admin
      t.float :value
      t.datetime :date
      t.string :paid_via, :limit => 30

      t.timestamps
    end
    add_index :payments, :user_id
    add_index :payments, :admin_id
  end
end
