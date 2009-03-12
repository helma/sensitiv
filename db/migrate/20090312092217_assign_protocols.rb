class AssignProtocols < ActiveRecord::Migration
  def self.up

    rename_table :protocols_outcomes, :outcomes_protocols

    p = Protocol.find(33)
    e = Experiment.find_by_name("derek")
    e.outcomes.each do |c|
      c.protocols << p
      c.save
    end
    e.protocols << p
    e.save

    p = Protocol.find(34)
    e = Experiment.find_by_name("phys_chem")
    e.treatments.each do |t|
      t.protocols << p
      t.save
      t.outcomes.each do |o|
        e.outcomes << o
      end
    end
    e.protocols << p
    e.save

    [3,4,5].each do |n|

      p = Protocol.find(n)
      [1,2,3].each do |i|
        e = Experiment.find(i)
        e.outcomes.each do |o|
          o.protocols << p
          o.save
        end
      end
      [9,10].each do |i|
        e = Experiment.find(i)
        e.outcomes.each do |o|
          o.protocols << p
          o.save
        end
        e.protocols << p
        e.save
      end

    end


  end

  def self.down
  end
end
