class FloatValue < ActiveRecord::Base

  has_many :outcomes, :as => :value

  def to_label
    value.to_s
  end
end
