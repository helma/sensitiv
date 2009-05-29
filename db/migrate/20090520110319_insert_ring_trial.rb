class InsertRingTrial < ActiveRecord::Migration
  def self.up
    rt = RingTrial.create(:name => "1")
    experiments = Experiment.find_all_by_workpackage_id(8).each do |e|
      e.update_attribute :ring_trial, rt
    end
    rt.save
  end

  def self.down
  end
end
