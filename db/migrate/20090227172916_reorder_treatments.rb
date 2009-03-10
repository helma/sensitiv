class Treatment  < ActiveRecord::Base
  belongs_to :compound
  belongs_to :bio_sample
  belongs_to :experiment
  belongs_to :dose, :class_name => "GenericData", :foreign_key => :dose_id
  belongs_to :duration, :class_name => "GenericData", :foreign_key => :duration_id
  belongs_to :solvent, :class_name => "Compound", :foreign_key => :solvent_id
  belongs_to :solvent_concentration, :class_name => "GenericData", :foreign_key => :solvent_concentration_id
  has_and_belongs_to_many :protocols
  has_many :measurments
end

class ReorderTreatments < ActiveRecord::Migration
  def self.up

    Experiment.find(:all).each do |e|

      case e.name
      when "llna"
      else 
        e.treatments.each do |t|
          if t.old_dose_id
            c = GenericData.find(t.old_dose_id)
            conc = Concentration.create(:value => c.value.value, :unit => c.unit) unless conc = Concentration.find_by_value_and_unit_id(c.value.value, c.unit.id)
            t.concentration_id = conc.id
            t.save
          end

          if t.old_duration_id
            d = GenericData.find(t.old_duration_id)
            dur = Duration.create(:value => d.value.value, :unit => d.unit) unless dur = Duration.find_by_value_and_unit_id(d.value.value, d.unit.id)
            t.duration_id = dur.id
            t.save
          end

          if t.old_solvent_id
            s = Compound.find(t.old_solvent_id)
            if t.solvent_concentration_id
              sc = GenericData.find(t.solvent_concentration_id)
              sconc = Concentration.create(:value => sc.value.value, :unit => sc.unit) unless sconc = Concentration.find_by_value_and_unit_id(sc.value.value, sc.unit.id)
              solv = Solvent.create(:compound => s, :concentration => sconc) unless solv = Solvent.find_by_compound_id_and_concentration_id(s.id, sconc.id)
              t.solvent_id = solv.id
              t.save
            else
              solv = Solvent.create(:compound => s) unless solv = Solvent.find_by_compound_id_and_concnetration.id(s.id,nil)
              t.solvent_id = solv.id
              t.save
            end
          end
        end
      end

    end
  end

  def self.down
  end
end
