#encoding: utf-8
if Role::where(:internal_name => :businness).any?
  role = Role::find_by_internal_name(:businness)
  role.internal_name = :business
  role.description = 'role business'
  role.save
end

Role.create :internal_name => :admin, :description => 'role admin' and puts 'role admin created' unless Role::where(:internal_name => :admin).any?
Role.create :internal_name => :personal, :description => 'role personal' and puts 'role personal created' unless Role::where(:internal_name => :personal).any?
Role.create :internal_name => :business, :description => 'role business' and puts 'role business created' unless Role::where(:internal_name => :business).any?
Role.create :internal_name => :sub_account, :description => 'role sub_account' and puts 'role sub_account created' unless Role::where(:internal_name => :sub_account).any?
Role.create :internal_name => :sub_account_with_admin, :description => 'sub account with admin rights' and puts 'role sub_account_with_admin created' unless Role::where(:internal_name => :sub_account_with_admin).any?
Role.create :internal_name => :driver, :description => 'role driver' and puts 'role driver created' unless Role::where(:internal_name => :driver).any?