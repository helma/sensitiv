class ReorderTreatments < ActiveRecord::Migration
  def self.up
    rename_column :treatments, :solvent_id, :old_solvent_id
    add_column :treatments, :solvent_id, :integer
    add_column :treatments, :concentration_id, :integer

    Treatment.find(:all).each do |t|

      if t.old_dose_id
        c = GenericData.find(t.old_dose_id)
        conc = Concentration.create(:value => c.value.value, :unit => c.unit) unless conc = Concentration.find_by_value(c.value.value) and conc.unit = c.unit
        t.concentration_id = conc.id
      end

      if t.old_duration_id
        d = GenericData.find(t.old_duration_id)
        dur = Duration.create(:value => d.value.value, :unit => d.unit) unless dur = Duration.find_by_value(d.value.value) and dur.unit = d.unit
        t.duration_id = dur.id
      end

      if t.old_solvent_id
        s = Compound.find(t.old_solvent_id)
        
        if t.solvent_concentration_id
          sc = GenericData.find(t.solvent_concentration_id)
          sconc = Concentration.create(:value => sc.value.value, :unit => sc.unit) unless sconc = Concentration.find_by_value(sc.value.value) and sconc.unit = sc.unit
        else
          sconc = nil
        end
        solv = Solvent.create(:compound => s, :concentration => sconc) unless solv = Solvent.find_by_compound_id(s.id) and solv.concentration = sconc
        t.solvent_id = solv.id
      end

      t.save
    end
  end

  def self.down
  end
end
