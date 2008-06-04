class Link < ActiveRecord::Base
  has_one :protocol, :as => :document

  def name
    url
  end
end

=begin
class InputsOutput < ActiveRecord::Base

  belongs_to :dag
  belongs_to :input, :polymorphic => true
  belongs_to :output, :polymorphic => true

  acts_as_double_polymorphic_join(
    :inputs => [:compounds, :bio_samples, :file_documents,:generic_datas],
    :outputs => [:file_documents,:generic_datas],
    :skip_duplicates => false
 )

end
=end

class MoveSensitivData  < ActiveRecord::Migration

  def self.up

    # create urls
    Protocol.find(:all).each do |p|
      if p.document.class == Link
        u = Url.create(:name => p.document.url)
        p.document = u
        p.save!
      end
    end

    cosmital_protocol = Protocol.create(:description => "Cosmital experimental description", :workpackage => Workpackage.find(2), :document => FileDocument.create(:file => File.open("db/migrate/data/cosmital_Experimental  description.doc")), :audited => false)

    cin = Compound.find_by_name("Cinnamic aldehyde")
    cin_unit = Unit.create(:name => "microgram_per_mL")
    dmso = Compound.create(:name => "DMSO")
    dmso_unit = Unit.find_by_name("percent_vol_per_vol")
    conc = Property.find_by_name("Concentration")

    dmso_concentration = GenericData.create(:property => conc, :value => FloatValue.create(:value => 0.5), :unit => dmso_unit)
    cin_concentration25 = GenericData.create(:property => conc, :value => FloatValue.create(:value => 2.5), :unit => cin_unit)
    cin_concentration5 = GenericData.create(:property => conc, :value => FloatValue.create(:value => 5), :unit => cin_unit)
    duration = GenericData.create(:property => Property.create(:name => "duration"), :value => FloatValue.create(:value => 24), :unit => Unit.create(:name => "hours"))

    affy = Property.find_by_name("Affymetrix File")

    if Experiment.find(:all)
      Experiment.find(:all).each do |e|
        puts e.name
        case e.id

        when 1
          e.bio_samples.each do |b|
            case b.organism_part
            when "blood"
              b.protocols << Protocol.find(2)
            when "tonsil"
              b.protocols << Protocol.find(1)
            end
            b.outputs.each do |o|
              d = GenericData.create(:property => affy, :value => o, :experiment => e, :sample => b)
              d.protocols << Protocol.find(3)
              d.protocols << Protocol.find(4)
              d.protocols << Protocol.find(5)
            end
          end

        when 2, 3 # cosmital
          cin.experiments << e
          e.bio_samples.each do |b|
            b.protocols << cosmital_protocol
            t = nil
            case b.name
            when "1744", "410", "420", "1824", "1825", "1826"
              t = Treatment.create(:solvent_id => dmso.id, :solvent_concentration_id => dmso_concentration.id, :duration_id => duration.id, :bio_sample => b, :experiment => e)
              t.protocols << cosmital_protocol
            when "423", "1827a", "1827b", "1827c"
              t = Treatment.create(:compound => cin, :dose_id => cin_concentration25.id, :solvent_id => dmso.id, :solvent_concentration_id => dmso_concentration.id, :duration_id => duration.id, :bio_sample => b, :experiment => e)
              t.protocols << cosmital_protocol
            when "1748", "412"
              t = Treatment.create(:compound => cin, :dose_id => cin_concentration5.id, :solvent_id => dmso.id, :solvent_concentration_id => dmso_concentration.id, :duration_id => duration.id, :bio_sample => b, :experiment => e)
              t.protocols << cosmital_protocol
            end
            b.outputs.each do |o|
              if t
                d = GenericData.create(:property => affy, :value => o, :experiment => e, :sample => t)
              else
                d = GenericData.create(:property => affy, :value => o, :experiment => e, :sample => b)
              end
              d.protocols << Protocol.find(3)
              d.protocols << Protocol.find(4)
              d.protocols << Protocol.find(5)
            end
          end

        when 4 # derek
          e.bio_samples.delete_all
          derek = Software.find(1)
          p = Protocol.create(:description => derek.name,:workpackage => Workpackage.find(1), :document => derek, :audited => true) unless p = Protocol.find_by_description(derek.name)
          e.compounds.each do |c|
            c.outputs.each do |data|
              if data.experiment == e
                data.update_attribute(:sample, c)
                data.protocols << p
              end
            end
          end

        when 5 # llna
          b = Organism.find_by_name("mouse").bio_samples[0]
          p = Protocol.find(25)
          e.compounds.each do |c|
            treatments = []
            solvent = nil
            ec3 = nil
            potency = nil
            c.outputs.each do |data|
              if data.experiment == e

                case data.property.name
                when "Vehicle"
                  solvent = Compound.create(:name => data.value.value) unless solvent = Compound.find_by_name(data.value.value)
                when "Stimulation Index"
                  t = Treatment.create(:compound => c, :bio_sample => b, :experiment => e, :protocols => [p])
                  data.update_attribute(:sample, t)
                  #t.generic_datas << data
                  data.protocols << p
                  data.inputs.each do |i|
                    t.update_attribute(:dose, i) if i.class == GenericData and i.property.name == "Concentration"
                  end
                  treatments << t
                when "EC3"
                  ec3 = DataTransformation.create(:result => data, :protocols => [p])
                  data.protocols << p
                when "Potency"
                  potency = DataTransformation.create(:result => data, :protocols => [p])
                  data.protocols << p
                end
              end
            end
            treatments.each do |t|
              t.update_attribute(:solvent, solvent)
              ec3.generic_datas << t.generic_datas
            end
            potency.generic_datas << ec3.result
          end

         when 6 # physchem
          toxnet = Url.create(:name => "http://toxnet.nlm.nih.gov/") unless toxnet =  Url.find_by_name("http://toxnet.nlm.nih.gov/")
          p = Protocol.create(:description => "TOXNET Database search", :workpackage => Workpackage.find(1), :document => toxnet, :audited => true) unless p = Protocol.find_by_description("TOXNET Database search")
          e.compounds.each do |c|
            c.outputs.each do |data|
              if data.experiment == e
                data.update_attribute(:sample, c)
                data.protocols << p
                puts "#{data.sample}"
              end
            end
          end

        when 7
        when 8
        else
          puts "no transformation rules for experiment #{e.id}"
        end
      end
    end

  end

end
