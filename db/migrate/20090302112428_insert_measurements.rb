
class Treatment  < ActiveRecord::Base

  belongs_to :compound
  belongs_to :bio_sample
  belongs_to :concentration
  belongs_to :duration
  belongs_to :solvent
  has_many :outcomes

  belongs_to :experiment
  has_and_belongs_to_many :protocols
has_many :generic_datas, :as => :sample

  def measurements
    outcomes.collect{ |r| r if r.type == "Measurement"}
  end

  def calculations
    outcomes.collect{ |r| r if r.type == "Calculation"}
  end

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
class Compound  < ActiveRecord::Base

  has_and_belongs_to_many :experiments
  has_many :treatments
  has_many :solvents

  def data_transformations
    results = []
    treatments.each do |t|
      t.generic_datas.each do |d|
        d.data_transformations.each do |t|
          results << t.result
        end
      end
    end
    results.uniq
  end


end
class DataTransformation  < ActiveRecord::Base
  has_and_belongs_to_many :generic_datas
  has_and_belongs_to_many :protocols
  belongs_to :result, :class_name => "GenericData", :foreign_key => :result_id
  belongs_to :experiment
end

class GenericData < ActiveRecord::Base

  belongs_to :sample, :polymorphic => true
  #has_and_belongs_to_many :protocols
  belongs_to :property
  belongs_to :value, :polymorphic => true
  belongs_to :unit
  belongs_to :experiment
  has_and_belongs_to_many :data_transformations

  def to_label
    label = self.value.to_label unless self.value.to_label.blank?
    label = label + ' ' + self.unit.name unless self.unit.blank?
    label
  end
end

class FileDatas < ActiveRecord::Base
  file_column :file#, :store_dir => "file_document/"
  has_one :protocol, :as => :document
  has_many :measurements, :as => :result

  def to_label
    file
  end
end

class InsertMeasurements < ActiveRecord::Migration

  def self.up

    Experiment.find(:all).each do |e|

      case e.name
      when "llna"
        b = BioSample.find(47)
        b.name = "Mouse (local lymph nodes)"
        b.save
        GenericData.find_all_by_experiment_id(e.id).each do |g|
          # identify measurements (as opposed to concentrations, ...
          case g.sample_type
          when "Treatment"
            treatment = g.sample
            treatment.bio_sample = b
            treatment.save
            Measurement.create(:property => g.property, :unit => g.unit, :treatment => treatment, :value => g.value, :experiment => g.experiment)
          end
        end
        # EC3 and potency (has been messed up in previous versions)
        ec3 = Property.find_by_name("EC3")
        potency = Property.find_by_name("Potency")
        e.compounds.each do |c|
          solvent = Treatment.find_by_experiment_id_and_compound_id(e.id,c.id).solvent
          c.data_transformations.each do |dt|
            treatment = Treatment.create(:compound => c, :experiment => e, :bio_sample => b, :solvent => solvent) 
            if p = dt.data_transformations[0].result
              Calculation.create(:property => p.property, :unit => p.unit, :treatment => treatment, :value => p.value) 
            end
            Calculation.create(:property => dt.property, :unit => dt.unit, :treatment => treatment, :value => dt.value) 
          end
        end
      when "derek"
        GenericData.find_all_by_experiment_id(e.id).each do |g|
          if g.sample_type == "Compound"
            treatment = Treatment.create(:compound => g.sample, :experiment => g.experiment) 
            Calculation.create(:property => g.property, :unit => g.unit, :treatment => treatment, :value => g.value, :experiment => g.experiment) 
          end
        end
      when "phys_chem"
        GenericData.find_all_by_experiment_id(e.id).each do |g|
          if g.sample_type == "Compound"
            treatment = Treatment.create(:compound => g.sample, :experiment => g.experiment) 
            Measurement.create(:property => g.property, :unit => g.unit, :treatment => treatment, :value => g.value) 
          end
        end
      when "invivoDC"
        GenericData.find_all_by_experiment_id(e.id).each do |g|
          if g.sample_type == "BioSample"
            treatment = Treatment.create(:bio_sample => g.sample, :experiment => g.experiment) 
            Measurement.create(:property => g.property, :unit => g.unit, :treatment => treatment, :value => g.value) 
          end
        end
      when /project/
        BioSample.find_all_by_experiment_id(e.id).each do |b|
          treatment = Treatment.create(:bio_sample => b, :experiment => b.experiment) 
          fname = b.name.sub(/~/,'_')
          f = FileDocument.find(:all, :conditions => ["file LIKE ?", "%#{fname}%"]) 
          if f.size > 1
            puts f
          else
            Measurement.create(:property => Property.find_by_name("Affymetrix File"), :treatment => treatment, :value => f[0]) 
          end
        end
      else 
        GenericData.find_all_by_experiment_id(e.id).each do |g|
          # identify measurements (as opposed to concentrations, ...
          case g.sample_type
          when "Treatment"
            treatment = g.sample
            Measurement.create(:property => g.property, :unit => g.unit, :treatment => treatment, :value => g.value, :experiment => g.experiment)
          end
        end
      end
    end

    # add cosmital samples without files
    ["1751","1755","1774","1776","400","402","403","404","409","413","418","419","422"].each do |n|
      bs = BioSample.find_by_name(n)
      treatment = Treatment.create(:bio_sample => bs, :experiment => bs.experiment) 
    end

    drop_table :generic_datas
  end

  def self.down
  end

end
