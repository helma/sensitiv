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

    create_table :results do |t|
      t.integer :property_id, :result_id, :unit_id, :treatment_id, :experiment_id
      t.string  :result_type
    end

    create_table :protocols_results, :id => false do |t|
      t.integer :result_id, :protocol_id
    end

=begin
    create_table :calculated_properties do |t|
      t.integer :property_id, :result_id, :unit_id, :compound_id
      t.string  :result_type
    end

    create_table :calculated_properties_protocols, :id => false do |t|
      t.integer :calculated_property_id, :protocol_id
    end

    create_table :measurement_aggregations, :id => false do |t|
      t.integer :property_id, :result_id, :unit_id
      t.string  :result_type
    end

    create_table :measurement_aggregations_protocols, :id => false do |t|
      t.integer :measurement_aggregations_id, :protoocol_id
    end

    create_table :measurements_measurement_aggregations, :id => false do |t|
      t.integer :measurement_aggregations_id, :measurement_id
    end
=end

  end

  def self.down
  end
end
