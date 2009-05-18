class CellLine < ActiveRecord::Base
	has_many :bio_samples
  has_many :dose_response_curves
  has_many :dose_response_sheets
end
