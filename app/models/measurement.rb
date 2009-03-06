class Measurement < Result

  belongs_to :treatment
  has_and_belongs_to_many :measurement_aggregations
  belongs_to :experiment

end
