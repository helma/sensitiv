class BoolValue < ActiveRecord::Base
  has_many :results, :as => :result
end
