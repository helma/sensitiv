class CleanTreatments < ActiveRecord::Migration
  def self.up
    remove_column :treatments, :old_dose_id
    remove_column :treatments, :dose_id
    remove_column :treatments, :old_duration_id
    remove_column :treatments, :old_solvent_id
    remove_column :treatments, :solvent_concentration_id
    Treatment.reset_column_information
  end

  def self.down
  end
end
