class DoseResponseSheet < ActiveRecord::Base
  has_and_belongs_to_many :dose_response_curves
  belongs_to :cell_line
  belongs_to :duration
end
