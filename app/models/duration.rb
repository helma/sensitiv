class Duration  < ActiveRecord::Base

  belongs_to :unit
  has_many :treatments
  has_many :dose_response_curves
  has_many :dose_response_sheets

  def name
    value.to_s + " " + unit.name
  end

end
