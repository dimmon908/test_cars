class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :name
      t.datetime :date
      t.binary :params
      t.binary :results
      t.timestamps
    end
    add_index :reports, :name
  end
end
