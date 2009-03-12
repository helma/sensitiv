class CompactTreatments < ActiveRecord::Migration
  def self.up
    Experiment.find(:all).each do |e|
      case e.name
      when /derek|phys_chem/
        e.compounds.each do |c|
          outcomes = []
          c.treatments.each do |t|
            if t.experiment == e
              outcomes << t.outcomes
              Treatment.delete(t.id)
            end
          end
          new_t = Treatment.create(:compound => c, :experiment => e)
          new_t.outcomes << outcomes
          new_t.save
        end
      end
    end
  end

  def self.down
  end
end
