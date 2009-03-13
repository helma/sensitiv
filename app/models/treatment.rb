# This class associates measurements (raw generic_data) with bio_samples and compounds
# Special cases:
# bio_samples without compound: biocharacteristics experiments, negative controls
# compounds without bio_ѕamples: physical/chemical measurements

class Treatment  < ActiveRecord::Base

  belongs_to :compound
  belongs_to :bio_sample
  belongs_to :concentration
  belongs_to :duration
  belongs_to :solvent
  has_many :outcomes

  belongs_to :experiment
  has_and_belongs_to_many :protocols

  def measurements
    outcomes.collect{ |r| r if r.type == "Measurement"}
  end

  def calculations
    outcomes.collect{ |r| r if r.type == "Calculation"}
  end

  def name
    label = ''
    begin
      label += "Sample " + bio_sample.name if bio_sample and bio_sample.name
      label += " treated with " unless label.blank? or compound.blank?
      label += compound.name if compound
    rescue
      label = "-"
    end
    label
  end

end
