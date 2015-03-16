class AddEmailToTermsApplication < ActiveRecord::Migration
  def change
    add_column :terms_applications, :first_name, :string
    add_column :terms_applications, :last_name, :string
    add_column :terms_applications, :email, :string
    add_column :terms_applications, :phone_code, :string
    add_column :terms_applications, :phone, :string
    add_column :terms_applications, :job_title, :string

  end
end
