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

    GenericData.find(:all).each do |g|
      # identify measurements (as opposed to concentrations, ...
      case g.sample_type
      when "Treatment"
        treatment = g.sample
        #puts treatment
        Measurement.create(:property => g.property, :unit => g.unit, :treatment => treatment, :result => g.value, :experiment => g.experiment)#, :experiment => g.experiment
      when nil
        if g.experiment and g.experiment.name == "llna"
          #case treatment.property.name
        else
          #puts "#{g.property.name}: #{g.value.value if g.value.value} (#{g.experiment.name if g.experiment})"
        end
      when "Compound"
        case g.experiment.name
        when "derek"
          treatment = Treatment.create(:compound => g.sample, :bio_sample => Experiment.find_by_name("llna").bio_samples[0], :experiment => g.experiment) #, :experiment => g.experiment
          CalculatedProperty.create(:property => g.property, :unit => g.unit, :treatment => treatment, :result => g.value, :experiment => g.experiment) #, :experiment => g.experiment
        when "phys_chem"
          treatment = Treatment.create(:compound => g.sample, :experiment => g.experiment) #, :experiment => g.experiment
          Measurement.create(:property => g.property, :unit => g.unit, :treatment => treatment, :result => g.value) #, :experiment => g.experiment
        else
          puts "#{g.sample.name} -> #{g.property.name} (#{g.experiment.name})"
        end
        # create calculation results

      when "BioSample"
        treatment = Treatment.create(:bio_sample => g.sample, :experiment => g.experiment) #, :experiment => g.experiment
        Measurement.create(:property => g.property, :unit => g.unit, :treatment => treatment, :result => g.value, :experiment => g.experiment) #, :experiment => g.experiment
      end

    end
    
    drop_table :generic_datas
  end

  def self.down
  end
end
