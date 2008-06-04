class CreateExperimentsWorkpackages < ActiveRecord::Migration
  def self.up
    add_column :experiments, :workpackage_id, :integer
    Experiment.reset_column_information
  end

  def self.down
    remove_column :experiments, :workpackage_id
  end
end
