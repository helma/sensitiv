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
  has_many :measurements
  has_many :calculated_properties

  belongs_to :experiment
  has_and_belongs_to_many :protocols

  def to_label
    label = ''
    begin
      label += "BioSample: "
      if bio_sample
        if bio_sample.name
          label += bio_sample.name
        elsif bio_sample.organism and bio_sample.organism_part
          label += bio_sample.organism.name.capitalize + " " + bio_sample.organism_part.name 
        else
          label = bio_sample.id.to_s
        end
      else
        label += '-'
      end
      label += "<br/>Compound: " 
      if compound
        label += compound.name 
      else
        label += '-'
      end
      label += "<br/>Dose: " 
      if dose
        #label += " ("  + dose.id + ")"
        #label += " (" + dose.value.value + ' ' + dose.unit + ")"
        #label += " ("  + dose.unit + ")"
      end
      label += "<br/>Duration: " 
      if duration
        #label += durattion.value
      end
      label += "<br/>Solvent: " 
      if solvent
        label += solvent.name
      else
        label += '-'
      end
    rescue
    end
    label
  end

end
