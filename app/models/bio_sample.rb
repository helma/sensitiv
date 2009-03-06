class BioSample < ActiveRecord::Base

	belongs_to :organism
	belongs_to :organism_part
	belongs_to :developmental_stage
	belongs_to :sex
  belongs_to :individual
	belongs_to :cell_line
	belongs_to :cell_type
  belongs_to :growth_condition
  has_and_belongs_to_many :protocols
  belongs_to :experiment
  has_many :treatments

end
