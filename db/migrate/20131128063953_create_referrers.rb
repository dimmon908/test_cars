class CreateReferrers < ActiveRecord::Migration
  def change
    create_table :referrers do |t|
      t.references :user
      t.string :email, :limit => 100
      t.string :provider, :limit => 30
      t.datetime :sended

      t.timestamps
    end
    add_index :referrers, :user_id
  end
end
