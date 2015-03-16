class PromoCodeHistory < ActiveRecord::Base
  belongs_to :user
  belongs_to :promo_code
  belongs_to :request
  # attr_accessible :title, :body
end
