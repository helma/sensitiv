class CreateRingTrials < ActiveRecord::Migration
  def self.up
    create_table :ring_trials do |t|
      t.string :name, :endpoint_names, :compound_names, :dose_response_curves, :control_dose_response_curves
      t.timestamps
    end
    add_column :experiments, :ring_trial_id, :integer
  end

  def self.down
    remove_column :experiments, :ring_trial_id
    drop_table :ring_trials
  end
end
