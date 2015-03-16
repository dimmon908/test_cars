#encoding: utf-8
class Article < ActiveRecord::Base
  attr_accessible :body, :headers, :url
end
