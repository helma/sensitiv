class Concentration  < ActiveRecord::Base
  has_many :treatments
  has_many :solvents
  belongs_to :unit
end
