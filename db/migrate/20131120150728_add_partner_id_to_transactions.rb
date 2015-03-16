class AddPartnerIdToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :partner_id, :integer
  end
end
