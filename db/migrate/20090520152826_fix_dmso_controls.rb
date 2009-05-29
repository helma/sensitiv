class FixDmsoControls < ActiveRecord::Migration
  def self.up
    Experiment.find_all_by_workpackage_id(8).each do |e|
      e.treatments.each do |t|
        if t.compound.nil?
          t.update_attribute(:compound, t.solvent.compound)
          t.update_attribute(:concentration, t.solvent.concentration)
          t.update_attribute(:solvent, nil)
        end
      end
    end
  end

  def self.down
  end
end
