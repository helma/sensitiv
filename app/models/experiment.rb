class Experiment < ActiveRecord::Base

	has_and_belongs_to_many :people
	has_and_belongs_to_many :protocols
  has_and_belongs_to_many :compounds
	has_many :results
	has_many :bio_samples
  belongs_to :workpackage

end
