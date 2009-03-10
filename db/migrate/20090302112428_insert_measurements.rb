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
