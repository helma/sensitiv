class GenericData < ActiveRecord::Base

  belongs_to :sample, :polymorphic => true
  #has_and_belongs_to_many :protocols
  belongs_to :property
  belongs_to :value, :polymorphic => true
  belongs_to :unit
  belongs_to :experiment
  has_and_belongs_to_many :data_transformations

  def to_label
    label = self.value.to_label unless self.value.to_label.blank?
    label = label + ' ' + self.unit.name unless self.unit.blank?
    label
  end
end

class CreateMeasurements < ActiveRecord::Migration

  def self.up

    create_table :outcomes do |t|
      t.integer :property_id, :value_id, :unit_id, :treatment_id, :experiment_id
      t.string  :type, :value_type
    end

    create_table :protocols_outcomes, :id => false do |t|
      t.integer :outcome_id, :protocol_id
    end

  end

  def self.down
  end
end
