class Solvent < ActiveRecord::Base
  belongs_to :compound
  belongs_to :concentration
  has_many :treatments
end
