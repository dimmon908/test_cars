#encoding: utf-8
class CreateConfigGroups < ActiveRecord::Migration
  def change
    create_table :config_groups, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :internal_name, :limit => 50
      t.string :public_name

      t.timestamps
    end
  end
end
