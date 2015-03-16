#encoding: utf-8
class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.references :user
      t.references :request
      t.integer :type
      t.integer :status
      t.decimal :base, :precision => 15, :scale => 10
      t.decimal :tax, :precision => 15, :scale => 10
      t.decimal :penalty, :precision => 15, :scale => 10
      t.decimal :summ, :precision => 15, :scale => 10
      t.decimal :gratuity, :precision => 15, :scale => 10
      t.decimal :total, :precision => 15, :scale => 10
      t.decimal :paid, :precision => 15, :scale => 10
      t.datetime :paid_stamp
      t.string :comment

      t.timestamps
    end
    add_index :transactions, :user_id
    add_index :transactions, :request_id
  end
end
