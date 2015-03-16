class AddSpecGratuityToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :spec_gratuity, :decimal, :precision => 12, :scale => 2
  end
end
