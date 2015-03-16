#encoding: utf-8
class ChangeCardNumberToCreditCardInfo < ActiveRecord::Migration
  def up
    change_column :credit_card_info, :card_number, :string, :limit => 50
  end
end
