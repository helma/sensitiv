class Property < ActiveRecord::Base
  has_many :outcomes
  has_many :dose_response_curves
end
