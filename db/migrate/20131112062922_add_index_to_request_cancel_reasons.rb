# encoding: UTF-8
class AddIndexToRequestCancelReasons < ActiveRecord::Migration
  def change
    add_index :request_cancel_reasons, :reason, :unique => true
  end
end
