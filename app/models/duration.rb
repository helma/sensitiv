class Duration  < ActiveRecord::Base
  belongs_to :unit
  has_many :treatments

  def name
    value.to_s + " " + unit.name
  end
end
