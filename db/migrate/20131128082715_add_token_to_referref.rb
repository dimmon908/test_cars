class AddTokenToReferref < ActiveRecord::Migration
  def change
    add_column :referrers, :token, :string
    add_index  :referrers, :token
  end
end
