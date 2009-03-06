class Solvent < ActiveRecord::Base

  belongs_to :compound
  belongs_to :concentration
  has_many :treatments

  def name
    name = compound.name
    name += " (" + concentration.value.to_s + " " + concentration.unit.name + ")" if concentration
    name
  end

end
