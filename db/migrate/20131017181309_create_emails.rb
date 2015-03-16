#encoding: utf-8
class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :internal_name
      t.string :title
      t.string :body_template
      t.integer :sort_order

      t.timestamps
    end
  end
end
