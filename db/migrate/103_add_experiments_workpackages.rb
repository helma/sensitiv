class AddExperimentsWorkpackages < ActiveRecord::Migration
  def self.up
    Experiment.find(1).update_attribute("workpackage_id",2)
    Experiment.find(2).update_attribute("workpackage_id",2)
    Experiment.find(3).update_attribute("workpackage_id",2)
    Experiment.find(4).update_attribute("workpackage_id",1)
    Experiment.find(5).update_attribute("workpackage_id",1)
    Experiment.find(6).update_attribute("workpackage_id",1)
    Experiment.find(7).update_attribute("workpackage_id",5)
    Experiment.find(8).update_attribute("workpackage_id",5)
  end

  def self.down
  end
end
