class BoolValue < ActiveRecord::Base
  has_many :outcomes, :as => :value
end
