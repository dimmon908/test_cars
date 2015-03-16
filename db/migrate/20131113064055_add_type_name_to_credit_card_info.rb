# encoding: UTF-8
class AddTypeNameToCreditCardInfo < ActiveRecord::Migration
  def change
    add_column :credit_card_info, :type_name, :string, :limit => 50
  end
end
