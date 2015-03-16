class AddApproveInfoToBusinessInfo < ActiveRecord::Migration
  def change
    add_column :business_infos, :credit_limit, :float
    add_column :business_infos, :credit, :float
    add_column :business_infos, :terms, :integer
  end
end
