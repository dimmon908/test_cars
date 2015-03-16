#encoding: utf-8
class Authentications < ActiveRecord::Base
  belongs_to :user
  attr_accessible :provider, :token, :token_secret, :uid
end
