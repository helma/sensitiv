class Concentration  < ActiveRecord::Base
  has_many :treatments
  has_many :solvents
  belongs_to :unit

  def name
    value.to_s + " " + unit.name
  end
end
