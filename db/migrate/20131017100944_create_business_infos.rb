#encoding: utf-8
class CreateBusinessInfos < ActiveRecord::Migration
  def change
    create_table :business_infos, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :name
      t.integer :type
      t.integer :year_in_business
      t.string :duns_number
      t.string :company_address
      t.string :billing_address
      t.string :email
      t.string :phone, :limit => 50
      t.integer :requests_per_month
      t.integer :employees
      t.decimal :credit_line, :precision => 15, :scale => 10
      t.integer :choose_payment
      t.boolean :approve_terms

      t.timestamps
    end
  end
end
