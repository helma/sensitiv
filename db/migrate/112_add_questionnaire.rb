class AddQuestionnaire < ActiveRecord::Migration
  def self.up
    create_table :survey_experiments do |t|
      t.string :description, :purpose, :cell_line, :measurements, :remarks
      t.boolean :standardised_sop, :treatment, :time_course, :dose_response, :finished
      t.integer :workpackage_id
    end
    create_table :survey_database_purposes do |t|
      t.boolean :data_backup, :data_dissemination, :data_analysis
      t.string :other, :comment
      t.integer :workpackage_id
    end
    create_table :survey_analysis_purposes do |t|
      t.boolean :biomarker_identification, :pathway_identification, :evaluation_of_experimental_conditions, :assay_comparison
      t.string :other, :comment
      t.integer :workpackage_id
    end
  end

  def self.down
    drop_table :survey_analysis_purposes
    drop_table :survey_database_purposes
    drop_table :survey_experiments
  end
end
