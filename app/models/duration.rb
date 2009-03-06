class Duration  < ActiveRecord::Base
  belongs_to :unit
  has_many :treatments
end
