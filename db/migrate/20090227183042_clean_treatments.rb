class CleanTreatments < ActiveRecord::Migration
  def self.up
    remove_column :treatments, :old_dose_id
    remove_column :treatments, :dose_id
    remove_column :treatments, :old_duration_id
    remove_column :treatments, :old_solvent_id
    remove_column :treatments, :solvent_concentration_id
    #rename_table :file_documents, :file_datas
  end

  def self.down
  end
end
