class ChangeBlobEncrypted < ActiveRecord::Migration
  def change
    add_column :credit_card_info, :enc_card_number, :binary
    add_column :credit_card_info, :enc_cvv, :binary
  end
end
