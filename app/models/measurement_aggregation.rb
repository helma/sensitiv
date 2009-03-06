class MeasurementAggregation < Result

  has_and_belongs_to_many :measurements

  def to_label
    label = self.value.to_label unless self.value.to_label.blank?
    label = label + ' ' + self.unit.name unless self.unit.blank?
    label
  end

end
