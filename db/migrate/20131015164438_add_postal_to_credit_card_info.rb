#encoding: utf-8
class AddPostalToCreditCardInfo < ActiveRecord::Migration
  def change
    add_column :credit_card_info, :postal_code, :string
  end
end
