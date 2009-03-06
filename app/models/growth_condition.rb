class GrowthCondition < ActiveRecord::Base
  has_many :bio_samples

  def name
    description
  end
end
