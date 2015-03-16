class AddEncrypted < ActiveRecord::Migration
  def change
    add_column :credit_card_info, :encrypted, :boolean, :default => false
  end
end
