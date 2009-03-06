class Result < ActiveRecord::Base

  has_and_belongs_to_many :protocols
  belongs_to :property
  belongs_to :result, :polymorphic => true
  belongs_to :unit
  belongs_to :experiment

  def to_label
    label = self.value.to_label unless self.value.to_label.blank?
    label = label + ' ' + self.unit.name unless self.unit.blank?
    label
  end

end
