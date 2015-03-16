#encoding: utf-8
class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.string :url
      t.string :headers
      t.text :body

      t.timestamps
    end
  end
end
