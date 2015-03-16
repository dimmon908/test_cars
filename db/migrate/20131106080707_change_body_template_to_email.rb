# encoding: UTF-8
class ChangeBodyTemplateToEmail < ActiveRecord::Migration
  def change
    change_column :emails, :body_template, :text
  end
end
