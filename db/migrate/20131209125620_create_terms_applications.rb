class CreateTermsApplications < ActiveRecord::Migration
  def change
    create_table :terms_applications do |t|
      t.references :user
      t.datetime :received
      t.datetime :approved
      t.references :admin

      t.timestamps
    end
    add_index :terms_applications, :user_id
    add_index :terms_applications, :admin_id
  end
end
