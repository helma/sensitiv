class Result < ActiveRecord::Base

  has_and_belongs_to_many :protocols
  belongs_to :property
  belongs_to :result, :polymorphic => true
  belongs_to :unit
  belongs_to :experiment

  def name
    name = property.name + ": " + result.value.to_s #unless result.value.blank?
    name += " " + unit.name if unit
    name
  end

end
