class DoseResponseCurve < ActiveRecord::Base
  has_and_belongs_to_many :dose_response_sheets
  belongs_to :compound
  belongs_to :result
  belongs_to :cell_line
  belongs_to :property
  belongs_to :duration
  belongs_to :unit#, :through => :concentration_unit_id
  file_column :image
end
