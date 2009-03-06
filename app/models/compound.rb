class Compound  < ActiveRecord::Base

  has_and_belongs_to_many :experiments
  has_many :treatments
  has_many :solvents

end
