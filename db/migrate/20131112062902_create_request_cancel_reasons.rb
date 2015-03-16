# encoding: UTF-8
class CreateRequestCancelReasons < ActiveRecord::Migration
  def change
    create_table :request_cancel_reasons, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :reason, :limit => 30
      t.string :comment

      t.timestamps
    end
  end
end
