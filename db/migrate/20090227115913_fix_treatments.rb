class Treatment  < ActiveRecord::Base
  belongs_to :compound
  belongs_to :bio_sample
  belongs_to :experiment
  belongs_to :dose, :class_name => "GenericData", :foreign_key => :dose_id
  belongs_to :duration, :class_name => "GenericData", :foreign_key => :duration_id
  belongs_to :solvent, :class_name => "Compound", :foreign_key => :solvent_id
  belongs_to :solvent_concentration, :class_name => "GenericData", :foreign_key => :solvent_concentration_id
  has_and_belongs_to_many :protocols
  has_many :measurments
end

class FixTreatments < ActiveRecord::Migration

  def self.up

    drop_table :chemical_elements
    rename_column :treatments, :dose_id, :old_dose_id
    rename_column :treatments, :duration_id, :old_duration_id
    rename_column :treatments, :solvent_id, :old_solvent_id
    add_column :treatments, :solvent_id, :integer
    add_column :treatments, :concentration_id, :integer
    add_column :treatments, :outcome_id, :integer
    add_column :treatments, :duration_id, :integer
    Treatment.reset_column_information

    create_table :concentrations do |t|
      t.float :value
      t.integer :unit_id
    end

    create_table :durations do |t|
      t.float :value
      t.integer :unit_id
    end

    create_table :solvents do |t|
      t.integer :compound_id, :concentration_id
    end

  end

  def self.down
  end
end
