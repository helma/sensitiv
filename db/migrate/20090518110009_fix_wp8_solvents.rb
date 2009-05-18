class FixWp8Solvents < ActiveRecord::Migration
  def self.up

    Experiment.find_all_by_workpackage_id(8).collect{|e| e.treatments}.flatten.each do |t|
      unit = Unit.find_by_name("% vol/vol")
      conc = Concentration.find_by_value_and_unit_id(0.1,unit.id)
      dmso = Compound.find_by_name('DMSO')
      solvent = Solvent.find_by_compound_id_and_concentration_id(dmso,conc)
      if t.compound
        case t.compound.name
        when "1-Chloro-2,4-dinitrobenzene"
          t.update_attribute(:solvent,solvent)
        when "Salicylic acid"
          t.update_attribute(:solvent,solvent)
        end
      end
    end

  end

  def self.down
  end
end
