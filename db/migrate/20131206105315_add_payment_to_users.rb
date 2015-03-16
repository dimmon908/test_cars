class AddPaymentToUsers < ActiveRecord::Migration
  def change
    add_column :user_profile, :payment, :string, :limit => 30
  end
end
