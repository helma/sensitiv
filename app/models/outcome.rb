class Outcome < ActiveRecord::Base

  belongs_to :treatment
  has_and_belongs_to_many :protocols
  belongs_to :property
  belongs_to :value, :polymorphic => true
  belongs_to :unit
  belongs_to :experiment

  def name
    name = ''
    name += property.name + ": " if property
    name += data if data
    name += " " + unit.name if unit
    name
  end

  def data
    value.value.to_s if value.value
  end

end
